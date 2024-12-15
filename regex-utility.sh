#!/bin/bash

# NOTE: Thanks to https://stackoverflow.com/a/73324448:

# Bash's built-in regular expression matching requires the regular expression
# to be unqouted (see https://stackoverflow.com/q/218156), which makes it harder
# to use some special characters, e.g., the dollar sign.
# This wrapper works around the issue by using a local variable, which means the
# quotes are not passed on to the regex engine.
function regexMatch() {
    local string="${1?}"
    local regex="${2?}"
    # shellcheck disable=SC2046 `regex` is deliberately unquoted, see above.
    [[ "${string}" =~ ${regex} ]]
}

# EXAMPLE USAGE:
# if regexMatch "$inputString" 'Date: ([0-9]{4}-[0-9]{2}-[0-9]{2})'; then
#     extracted_date="${BASH_REMATCH[1]}"
#     echo "Extracted Date: $extracted_date"
# else
#     echo "Date not found"
# fi
