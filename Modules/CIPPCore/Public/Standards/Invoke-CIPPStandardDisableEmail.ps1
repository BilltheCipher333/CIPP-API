function Invoke-CIPPStandardDisableEmail {
    <#
    .FUNCTIONALITY
        Internal
    .COMPONENT
        (APIName) DisableEmail
    .SYNOPSIS
        (Label) Disables Email as an MFA method
    .DESCRIPTION
        (Helptext) This blocks users from using email as an MFA method. This disables the email OTP option for guest users, and instead promts them to create a Microsoft account.
        (DocsDescription) This blocks users from using email as an MFA method. This disables the email OTP option for guest users, and instead promts them to create a Microsoft account.
    .NOTES
        CAT
            Entra (AAD) Standards
        TAG
            "highimpact"
        ADDEDCOMPONENT
        IMPACT
            High Impact
        POWERSHELLEQUIVALENT
            Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration
        RECOMMENDEDBY
        UPDATECOMMENTBLOCK
            Run the Tools\Update-StandardsComments.ps1 script to update this comment block
    .LINK
        https://docs.cipp.app/user-documentation/tenant/standards/edit-standards
    #>

    param($Tenant, $Settings)
    ##$Rerun -Type Standard -Tenant $Tenant -Settings $Settings 'DisableEmail'

    $CurrentState = New-GraphGetRequest -Uri 'https://graph.microsoft.com/beta/policies/authenticationmethodspolicy/authenticationMethodConfigurations/Email' -tenantid $Tenant
    $StateIsCorrect = ($CurrentState.state -eq 'disabled')

    If ($Settings.remediate -eq $true) {
        if ($StateIsCorrect -eq $true) {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Email authentication method is already disabled.' -sev Info
        } else {
            try {
                Set-CIPPAuthenticationPolicy -Tenant $tenant -APIName 'Standards' -AuthenticationMethodId 'Email' -Enabled $false
                Write-LogMessage -API 'Standards' -tenant $tenant -message 'Email authentication method disabled' -sev Info
            } catch {
                Write-LogMessage -API 'Standards' -tenant $tenant -message 'Failed to disable Email authentication method' -sev Error -LogData $_
            }
        }
    }

    if ($Settings.alert -eq $true) {
        if ($StateIsCorrect -eq $true) {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Email authentication method is enabled' -sev Alert
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Email authentication method is not enabled' -sev Info
        }
    }

    if ($Settings.report -eq $true) {
        Add-CIPPBPAField -FieldName 'DisableEmail' -FieldValue $StateIsCorrect -StoreAs bool -Tenant $tenant
    }
}
