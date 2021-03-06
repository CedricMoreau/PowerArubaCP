#
# Copyright 2018-2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Service" {

    It "Get Service Does not throw an error" -Skip:$VersionBefore680 {
        {
            Get-ArubaCPService
        } | Should Not Throw
    }

    It "Get Service " -Skip:$VersionBefore680 {
        $s = Get-ArubaCPService
        $s.count | Should not be $NULL
    }

    It "Get Service id (id 1)" -Skip:$VersionBefore680 {
        $s = Get-ArubaCPService | Where-Object { $_.id -eq "1" }
        $s.id | Should be "1"
        $s.name | Should be "[Policy Manager Admin Network Login Service]"
        $s.type | Should be "TACACS"
        $s.template | Should be "TACACS_ENFORCEMENT"
        $s.enabled | Should be "True"
        $s.orderNo | Should be "1"
    }

    It "Get Network Device (id 1) and confirm (via Confirm-ArubaCPService)" -Skip:$VersionBefore680 {
        $s = Get-ArubaCPService | Where-Object { $_.id -eq "1" }
        Confirm-ArubaCPService $s | Should be $true
    }

    It "Search Service by id (1)" -Skip:$VersionBefore680 {
        $s = Get-ArubaCPService -id 1
        @($s).count | Should be 1
        $s.id | Should not be BeNullOrEmpty
        $s.name | Should be "[Policy Manager Admin Network Login Service]"
    }

    It "Search Service by id ([Policy Manager Admin Network Login Service])" -Skip:$VersionBefore680 {
        $s = Get-ArubaCPService -name '[Policy Manager Admin Network Login Service]'
        @($s).count | Should be 1
        $s.id | Should not be BeNullOrEmpty
        $s.name | Should be "[Policy Manager Admin Network Login Service]"
    }

    It "Search Network Device by name (contains *Policy*)" -Skip:$VersionBefore680 {
        $s = Get-ArubaCPService -name Policy -filter_type contains
        @($s).count | Should be 1
        $s.id | Should not be BeNullOrEmpty
        $s.name | Should be "[Policy Manager Admin Network Login Service]"
    }

    #Disable because freeze...
    # It "Search Service by attribute (type equal RADIUS)" {
    #     $s = Get-ArubaCPService -filter_attribute type -filter_type equal -filter_value RADIUS
    #     @($s).count | Should be 1
    #     $s.type | Should be "RADIUS"
    # }

    It "Get Service throw a error when use with CPPM <= 6.8.0" -Skip: ($VersionBefore680 -eq 0) {
        { Get-ArubaCPService } | Should throw "Need ClearPass >= 6.8.0 for use this cmdlet"
    }

}

Describe  "Enable / Disable Service" {

    It "Disable Service (id 1)" -Skip:$VersionBefore680 {
        $s = Get-ArubaCPService -id 1
        $s.enabled | Should be "True"
        $s = Get-ArubaCPService -id 1 | Disable-ArubaCPService
        $s.enabled | Should be "false"
    }

    It "Enable Service (id 1)" -Skip:$VersionBefore680 {
        $s = Get-ArubaCPService -id 1 | Enable-ArubaCPService
        $s.enabled | Should be "true"
    }

}

Disconnect-ArubaCP -noconfirm