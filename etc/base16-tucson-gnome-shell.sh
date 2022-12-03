#!/usr/bin/env bash
# Base16 Tucson - Gnome Terminal color scheme install script
# dkessler@acm.org 

[[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="Base 16 Tucson"
[[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="base-16-tucson"
[[ -z "$DCONF" ]] && DCONF=dconf
[[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

dset() {
    local key="$1"; shift
    local val="$1"; shift

    if [[ "$type" == "string" ]]; then
        val="'$val'"
    fi

    "$DCONF" write "$PROFILE_KEY/$key" "$val"
}

# Because dconf still doesn't have "append"
dlist_append() {
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "'$val'"
        } | head -c-1 | tr "\n" ,
    )"

    "$DCONF" write "$key" "[$entries]"
}

# Newest versions of gnome-terminal use dconf
if which "$DCONF" > /dev/null 2>&1; then
    # Check that uuidgen is available
    type $UUIDGEN >/dev/null 2>&1 || { echo >&2 "Requires uuidgen but it's not installed.  Aborting!"; exit 1; }

    [[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

    if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then
        if which "$UUIDGEN" > /dev/null 2>&1; then
            PROFILE_SLUG=`uuidgen`
        fi

        if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
            DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
        else
            DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
        fi

        DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
        PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

        # Copy existing settings from default profile
        $DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

        # Add new copy to list of profiles
        dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

        # Update profile values with theme options
        dset visible-name "'$PROFILE_NAME'"
        dset palette "['#141210', '#81613e', '#8bb365', '#e2cd3a', '#7bb198', '#a9405d', '#69715b', '#a99670', '#4b4942', '#ee9b1b', '#201e1b', '#47443f', '#908061', '#c3b291', '#793efd', '#e6dbc4']"
        dset background-color "'#141210'"
        dset foreground-color "'#a99670'"
        dset bold-color "'#a99670'"
        dset bold-color-same-as-fg "true"
        dset cursor-colors-set "true"
        dset cursor-background-color "'#a99670'"
        dset cursor-foreground-color "'#141210'"
        dset use-theme-colors "false"
        dset use-theme-background "false"

        unset PROFILE_NAME
        unset PROFILE_SLUG
        unset DCONF
        unset UUIDGEN
        exit 0
    fi
fi

# Fallback for Gnome 2 and early Gnome 3
[[ -z "$GCONFTOOL" ]] && GCONFTOOL=gconftool
[[ -z "$BASE_KEY" ]] && BASE_KEY=/apps/gnome-terminal/profiles

PROFILE_KEY="$BASE_KEY/$PROFILE_SLUG"

gset() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    "$GCONFTOOL" --set --type "$type" "$PROFILE_KEY/$key" -- "$val"
}

# Because gconftool doesn't have "append"
glist_append() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$GCONFTOOL" --get "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "$val"
        } | head -c-1 | tr "\n" ,
    )"

    "$GCONFTOOL" --set --type list --list-type $type "$key" "[$entries]"
}

# Append the Base16 profile to the profile list
glist_append string /apps/gnome-terminal/global/profile_list "$PROFILE_SLUG"

gset string visible_name "$PROFILE_NAME"
gset string palette "#141210:#81613e:#8bb365:#e2cd3a:#7bb198:#a9405d:#69715b:#a99670:#4b4942:#81613e:#8bb365:#e2cd3a:#7bb198:#a9405d:#69715b:#e6dbc4"
gset string palette "['#141210', '#81613e', '#8bb365', '#e2cd3a', '#7bb198', '#a9405d', '#69715b', '#a99670', '#4b4942', '#ee9b1b', '#201e1b', '#47443f', '#908061', '#c3b291', '#793efd', '#e6dbc4']"
gset string background_color "#141210"
gset string foreground_color "#a99670"
gset string bold_color "#a99670"
gset bool   bold_color_same_as_fg "true"
gset bool   cursor-colors-set "true"
gset string cursor-background-color "'#a99670'"
gset string cursor-foreground-color "'#141210'"
gset bool   use_theme_colors "false"
gset bool   use_theme_background "false"

unset PROFILE_NAME
unset PROFILE_SLUG
unset DCONF
unset UUIDGEN
