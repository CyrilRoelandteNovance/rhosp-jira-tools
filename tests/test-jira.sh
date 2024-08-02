#!/bin/bash
# Copyright 2024      Red Hat, Inc

set -u
TOPDIR=$(cd $(dirname "$0") && pwd)/..
JIRA="$TOPDIR/bin/jira"
source "$JIRA"

JIRATOKEN=$(jira_get_token)
# TODO: Unhardcode this
JIRAAPIURL=https://issues.redhat.com/rest/api/2

_get_json () {
    # Return the JSON describing the issue whose is is passed as a parameter
    curl -s  \
       -X GET \
       -H "Authorization: Bearer $JIRATOKEN" \
       -H "Content-Type: application/json" \
        "$JIRAAPIURL/issue/$1/"
}

test_edit_status () {
    issue=OSP-24252
    json=$(_get_json "$issue")
    status=$(jq -r '.fields.status.name' <<< "$json")
    # We are either going from "New" to "In Progress" or the other way around,
    # depending on the initial status.
    [[ "$status" == "New" ]] && newstatus="In Progress" || newstatus=New
    echo "Changing status from $status to $newstatus"
    $JIRA edit --set-status "$newstatus" "$issue"
    json=$(_get_json "$issue")
    status=$(jq -r '.fields.status.name' <<< "$json")
    if [[ "$status" != "$newstatus" ]]; then
        echo "Failed to set status to $newstatus for $issue"
        echo "KO"
        return
    fi
    return 0
}

test_edit_custom_field_float () {
    # TODO: Make sure this does nothing on issues that are not Stories?
    issue=OSP-24253
    json=$(_get_json "$issue")
    points=$(jq -r '.fields.customfield_12310243' <<< "$json")
    [[ "$points" == 1.0 ]] && newpoints=2.0 || newpoints=1.0
    echo "Changing Story points from $points to $newpoints"
    $JIRA edit --set-Story-Points "$newpoints" "$issue"
    json=$(_get_json "$issue")
    points=$(jq -r '.fields.customfield_12310243' <<< "$json")
    if [[ "$points" != "$newpoints" ]]; then
        echo "Failed to set Story Points to $newpoints for $issue"
        return 1
    fi
    return 0
}

test_edit_custom_field_float_add_fails () {
    issue=OSP-24253
    if $JIRA edit --add-Story-Points "8" "$issue"; then
        echo "We managed to 'add' a value to a 'float' custom field."
        echo "This should not be possible."
        return 1
    fi
}

test_edit_custom_field_float_remove_fails () {
    issue=OSP-24253
    if $JIRA edit --remove-Story-Points "8" "$issue"; then
        echo "We managed to 'remove' a value from a 'float' custom field."
        echo "This should not be possible."
        return 1
    fi
}

test_edit_custom_field_select () {
    issue=OSP-24253
    json=$(_get_json "$issue")
    dev_approval=$(jq -r '.fields.customfield_12317260.value' <<< "$json")
    [[ "$dev_approval" == "Committed" ]] && \
        new_dev_approval=Targeted || new_dev_approval=Committed
    echo "Changing Dev-Approval from $dev_approval to $new_dev_approval"
    $JIRA edit --set-Dev-Approval "$new_dev_approval" "$issue"
    json=$(_get_json "$issue")
    dev_approval=$(jq -r '.fields.customfield_12317260.value' <<< "$json")
    if [[ "$dev_approval" != "$new_dev_approval" ]]; then
        echo "Failed to set Dev-Approval to $new_dev_approval for $issue"
        return 1
    fi
    return 0
}

test_edit_custom_field_select_add_fails () {
    issue=OSP-24253
    if $JIRA edit --add-Dev-Approval Committed "$issue"; then
        echo "We managed to 'add' a value to a 'select' custom field."
        echo "This should not be possible."
        return 1
    fi
}

test_edit_custom_field_select_remove_fails () {
    if $JIRA edit --remove-Dev-Approval Committed "$issue"; then
        echo "We managed to 'remove' a value from a 'select' custom field."
        echo "This should not be possible."
        return 1
    fi
}

test_edit_custom_field_textfield () {
    issue=OSP-24252
    json=$(_get_json "$issue")
    whiteboard=$(jq -r '.fields.customfield_12316843' <<< "$json")
    [[ "$whiteboard" == "foo" ]] && \
        new_whiteboard=bar || new_whiteboard=foo
    echo "Changing Whiteboard from $whiteboard to $new_whiteboard"
    $JIRA edit --set-Whiteboard "$new_whiteboard" "$issue"
    json=$(_get_json "$issue")
    whiteboard=$(jq -r '.fields.customfield_12316843' <<< "$json")
    if [[ "$whiteboard" != "$new_whiteboard" ]]; then
        echo "Failed to set Whiteboard to $new_whiteboard for $issue"
        return 1
    fi
    return 0
}

errors=0
testfuncs=(test_edit_status)
testfuncs+=(test_edit_custom_field_float)
testfuncs+=(test_edit_custom_field_float_add_fails)
testfuncs+=(test_edit_custom_field_float_remove_fails)
testfuncs+=(test_edit_custom_field_select)
testfuncs+=(test_edit_custom_field_select_add_fails)
testfuncs+=(test_edit_custom_field_select_remove_fails)
# No test for multiselect as we are no longer using the Workstream field. This
# should be tested, though.
testfuncs+=(test_edit_custom_field_textfield)
for testfunc in "${testfuncs[@]}"; do
    echo "[+] Running test $testfunc"
    $testfunc
    errors=$((errors + $?))
done

if [[ "$errors" = "0" ]]; then
    echo "SUCCESS"
else
    echo "FAIL: $errors failed test(s)"
fi
