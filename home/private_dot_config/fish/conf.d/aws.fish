#
#
#    __ ___      _____
#   / _` \ \ /\ / / __|
#  | (_| |\ V  V /\__ \
#   \__,_| \_/\_/ |___/
#
#

#######################################
# Switch AWS profiles
# Arguments:
#   profile: the profile to switch to.
#   mfa_token: the MFA token.
#######################################
function acp --description "Switch AWS profile with optional MFA and role assumption."
    if test (count $argv) -eq 0
        set -e AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE
        set -e AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
        echo "AWS profile cleared."
        return
    end

    set profile $argv[1]
    set mfa_token $argv[2]
    set profiles (aws_profiles)

    set -l config_file (or $AWS_CONFIG_FILE "$HOME/.aws/config")
    if not contains $profile $profiles
        echo "Profile '$profile' not found in '$config_file'"
        echo "Available profiles: $profiles"
        return 1
    end

    set aws_access_key_id (aws configure get aws_access_key_id --profile $profile)
    set aws_secret_access_key (aws configure get aws_secret_access_key --profile $profile)
    set aws_session_token (aws configure get aws_session_token --profile $profile)
    set mfa_serial (aws configure get mfa_serial --profile $profile)
    set session_duration (aws configure get duration_seconds --profile $profile)

    set -l mfa_opt
    if test -n "$mfa_serial"
        if test -z "$mfa_token"
            read -l -p "Please enter your MFA token for $mfa_serial: " mfa_token
        end
        if test -z "$session_duration"
            read -l -p "Enter session duration (900-43200, default 3600): " session_duration
        end
        set mfa_opt --serial-number "$mfa_serial" --token-code "$mfa_token" --duration-seconds (or $session_duration 3600)
    end

    set role_arn (aws configure get role_arn --profile $profile)
    set session_name (aws configure get role_session_name --profile $profile)

    if test -n "$role_arn"
        set source_profile (aws configure get source_profile --profile $profile)
        set session_name (or $session_name $source_profile)
        echo "Assuming role $role_arn using profile $source_profile"
        set credentials (aws sts assume-role \
            --role-arn "$role_arn" \
            $mfa_opt \
            --profile "$source_profile" \
            --role-session-name "$session_name" \
            --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
            --output text)
    else
        echo "Obtaining session token for profile $profile"
        set credentials (aws sts get-session-token \
            --profile "$profile" \
            $mfa_opt \
            --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
            --output text)
    end

    set parts (string split " " -- $credentials)
    set aws_access_key_id $parts[1]
    set aws_secret_access_key $parts[2]
    set aws_session_token $parts[3]

    if test -n "$aws_access_key_id"
        set -gx AWS_DEFAULT_PROFILE $profile
        set -gx AWS_PROFILE $profile
        set -gx AWS_EB_PROFILE $profile
        set -gx AWS_ACCESS_KEY_ID $aws_access_key_id
        set -gx AWS_SECRET_ACCESS_KEY $aws_secret_access_key
        set -gx AWS_SESSION_TOKEN $aws_session_token
        echo "Switched to AWS profile: $profile"
    end
end

#######################################
# Get the current AWSprofile
#######################################
function agp --description "Print the current AWS profile."
    echo $AWS_PROFILE
end

#######################################
# Get the current AWS region.
#######################################
function agr --description "Print the current AWS region."
    echo $AWS_REGION
end

#######################################
# List all AWS profiles.
#######################################
function aws_profiles --description "List all available AWS profiles."
    aws --no-cli-pager configure list-profiles 2>/dev/null
end

#######################################
# List all AWS regions using the active profile.
#######################################
function aws_regions --description "List AWS regions for the current profile."
    set -l region (or $AWS_DEFAULT_REGION $AWS_REGION "us-west-1")
    if test -n "$AWS_PROFILE" -o -n "$AWS_DEFAULT_PROFILE"
        aws ec2 describe-regions --region $region --output text --query 'Regions[*].RegionName'
    else
        echo "You must specify an AWS profile."
    end
end

#######################################
# Set the active AWS profile.
# Arguments:
#   sso: whether to perform SSO login / logout.
#######################################
function asp --description "Set AWS profile and optionally perform SSO login/logout."
    if test (count $argv) -eq 0
        set -e AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE AWS_PROFILE_REGION
        _aws_clear_state
        echo "AWS profile cleared."
        return
    end

    set profile $argv[1]
    set profiles (aws_profiles)

    set -l config_file (or $AWS_CONFIG_FILE "$HOME/.aws/config")
    if not contains $profile $profiles
        echo "Profile '$profile' not found in '$config_file'"
        echo "Available profiles: $profiles"
        return 1
    end

    set -gx AWS_DEFAULT_PROFILE $profile
    set -gx AWS_PROFILE $profile
    set -gx AWS_EB_PROFILE $profile
    set -gx AWS_PROFILE_REGION (aws configure get region)
    _aws_update_state

    switch "$argv[2]"
        case login
            if test (count $argv) -ge 3
                aws sso login --sso-session $argv[3]
            else
                aws sso login
            end
        case logout
            aws sso logout
    end
end

#######################################
# Set the active AWS region
#######################################
function asr --description "Set AWS region and update state."
    if test (count $argv) -eq 0
        set -e AWS_REGION AWS_DEFAULT_REGION
        _aws_update_state
        echo "AWS region cleared."
        return
    end

    set region $argv[1]
    set regions (aws_regions)

    if not contains $region $regions
        echo "Available regions:"
        echo $regions
        return 1
    end

    set -gx AWS_REGION $region
    set -gx AWS_DEFAULT_REGION $region
    _aws_update_state
end

#######################################
# Clears the AWS state file if enabled.
#######################################
function _aws_clear_state --description "Clear AWS state file if profile tracking is enabled."
    if test "$AWS_PROFILE_STATE_ENABLED" = true
        set -l dir (dirname $AWS_STATE_FILE)
        test -d $dir || return 1
        echo -n "" >"$AWS_STATE_FILE"
    end
end

#######################################
# Writes the current AWS profile/region to the state file.
#######################################
function _aws_update_state --description "Write AWS profile and region to state file if enabled."
    if test "$AWS_PROFILE_STATE_ENABLED" = true
        set -l dir (dirname $AWS_STATE_FILE)
        test -d $dir || return 1
        echo "$AWS_PROFILE $AWS_REGION" >"$AWS_STATE_FILE"
    end
end
