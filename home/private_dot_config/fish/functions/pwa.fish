#######################################
# Manage progressive web apps (PWAs).
# Arguments:
#   subcommand: add, remove.
#######################################
function pwa --description "Manage progressive web apps"
    set -l app_dir "$HOME/.local/share/applications"
    set -l icon_dir "$app_dir/icons"

    set -l op $argv[1]
    switch $op
        case add
            _pwa_add $app_dir $icon_dir
        case remove
            _pwa_remove $app_dir $argv[2..-1]
        case '*'
            echo "Usage: pwa <add|remove>"
    end
end

#######################################
# Create a new PWA desktop entry.
# Prompts for app name, URL, and icon.
# Arguments:
#   app_dir: applications directory.
#   icon_dir: icons directory.
#######################################
function _pwa_add
    set -l app_dir $argv[1]
    set -l icon_dir $argv[2]

    # Prompt for app details
    set -l name (gum input --prompt "App name: " --placeholder "My App")
    if test -z "$name"
        echo "App name is required." >&2
        return 1
    end

    set -l url (gum input --prompt "URL: " --placeholder "https://example.com")
    if test -z "$url"
        echo "App URL is required." >&2
        return 1
    end

    # Fetch icon
    set -l filename (_pwa_slugify $name)
    set -l icon_path "$icon_dir/$filename.png"
    mkdir -p $icon_dir
    set -l icon_url (gum input \
        --prompt "Icon: " \
        --header "Tip: find icons at https://dashboardicons.com")
    if test -z "$icon_url"; or not _pwa_download $icon_url $icon_path
        echo "Failed to fetch icon." >&2
        return 1
    end

    # Write desktop entry
    set -l desktop_path "$app_dir/$filename.desktop"
    _pwa_write_file $desktop_path $name $url $icon_path
    gum style \
        --border rounded --border-foreground 2 \
        --padding "0 1" --margin "1 0" \
        "Created PWA" "" \
        "Name  $name" \
        "URL   $url" \
        "File  $desktop_path"
end

#######################################
# Remove a PWA desktop entry.
# Deletes the desktop file and its icon.
# Arguments:
#   app_dir: applications directory.
#   name: (optional) app name to remove.
#######################################
function _pwa_remove
    set -l app_dir $argv[1]

    # Discover installed PWAs
    set -l pwa_files (_pwa_list $app_dir)
    if test (count $pwa_files) -eq 0
        echo "No PWAs found."
        return 0
    end

    # Resolve target desktop file
    set -l target (_pwa_select --header "Select PWA to remove:" $pwa_files $argv[2..-1])
    test -n "$target"; or return $status

    # Confirm removal
    # Read fields before deleting
    set -l app_name (_pwa_read_field $target Name)
    set -l app_url (_pwa_read_field $target Exec)
    set app_url (string replace 'chromium --app=' '' -- $app_url \
        | string trim --chars='"/')
    gum confirm "Remove '$app_name'?"; or return 0

    # Remove icon and desktop file
    set -l icon_path (_pwa_read_field $target Icon)
    test -f "$icon_path"; and rm -f $icon_path
    rm -f $target
    gum style \
        --border rounded --border-foreground 1 \
        --padding "0 1" --margin "1 0" \
        "Removed PWA" "" \
        "Name  $app_name" \
        "URL   $app_url" \
        "File  $target"
end

#######################################
# Download a file, returning success only if
# the download succeeded and the result is
# non-empty.
# Arguments:
#   url: source URL.
#   dest: destination file path.
#######################################
function _pwa_download
    curl -fsSL -o $argv[2] $argv[1] && test -s $argv[2]
end

#######################################
# List installed PWA desktop files.
# Arguments:
#   app_dir: applications directory.
# Outputs:
#   One file path per line to stdout.
#######################################
function _pwa_list
    set -l app_dir $argv[1]
    for f in $app_dir/*.desktop
        grep -q 'chromium --app=' $f 2>/dev/null; or continue
        echo $f
    end
end

#######################################
# Read a field value from a desktop file.
# Arguments:
#   file: desktop file path.
#   field: field name (e.g. Name, Icon).
# Outputs:
#   The field value to stdout.
#######################################
function _pwa_read_field
    grep "^$argv[2]=" $argv[1] | string replace "$argv[2]=" ''
end

#######################################
# Select a PWA by argument or fuzzy picker.
# Arguments:
#   --header: header text for interactive picker.
#   pwa_files: list of PWA file paths,
#     optionally followed by a name to match.
# Outputs:
#   Path to the selected desktop file.
#######################################
function _pwa_select
    argparse 'header=' -- $argv

    set -l pwa_files $argv

    # Direct match by argument
    if test (count $argv) -gt 0; and not string match -q "*.desktop" $argv[-1]
        set -l slug (_pwa_slugify $argv[-1])
        for f in $argv[1..-2]
            string match -q "*/$slug.desktop" $f; or continue
            echo $f
            return 0
        end
        echo "PWA not found: $argv[-1]" >&2
        return 1
    end

    # Build name-to-path mapping for interactive selection
    set -l names
    set -l paths
    for f in $pwa_files
        set -a names (_pwa_read_field $f Name)
        set -a paths $f
    end

    set -l selection (printf '%s\n' $names | gum filter --header "$_flag_header")
    test -n "$selection"; or return 1

    for i in (seq (count $names))
        test "$names[$i]" = "$selection"; or continue
        echo $paths[$i]
        return 0
    end
end

#######################################
# Convert a name to a kebab-case slug.
# Arguments:
#   name: name to convert.
# Outputs:
#   Slugified name to stdout.
#######################################
function _pwa_slugify
    string lower -- $argv | string replace -a ' ' -
end

#######################################
# Write a PWA desktop entry file.
# Arguments:
#   dest: destination file path.
#   name: application name.
#   url: application URL.
#   icon: icon file path.
#######################################
function _pwa_write_file
    printf '%s\n' \
        '#!/usr/bin/env xdg-open' \
        '[Desktop Entry]' \
        'Version=1.0' \
        'Terminal=false' \
        'Type=Application' \
        "Name=$argv[2]" \
        "Comment=$argv[2]" \
        "Exec=/usr/bin/chromium --app=\"$argv[3]\"" \
        "Icon=$argv[4]" \
        'StartupNotify=true' >$argv[1]
    chmod +x $argv[1]
end
