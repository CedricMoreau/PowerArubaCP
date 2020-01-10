#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Application License" {

    It "Get Application License Does not throw an error" {
        {
            Get-ArubaCPApplicationLicense
        } | Should Not Throw
    }

    It "Get ALL Application License" {
        $al = Get-ArubaCPApplicationLicense
        $al.count | Should not be $NULL
    }

    It "Get Application License and confirm" {
        $al = Get-ArubaCPApplicationLicense
        Confirm-ArubaCPApplicationLicense $al[0] | Should be $true
    }

}

Describe  "Add and Remove Application License" {

    It "Add Application License ($pester_license_type)" -Skip:($pester_license -eq $null) {
        #Add-ArubaCPApplicationLicense -product_name $pester_license_type -license_key $pester_license
        $al = Get-ArubaCPApplicationLicense -product_name $pester_license_type #Only check if search work !
        $al.id | Should not be BeNullOrEmpty
        $al.product_name | Should be $pester_license_type
    }

    It "Remove Application License ($pester_license_type)" -Skip:($pester_license -eq $null) {
        Get-ArubaCPApplicationLicense -product_name $pester_license_type | Remove-ArubaCPApplicationLicense -noconfirm
        $al = Get-ArubaCPApplicationLicense -product_name $pester_license_type
        $al | Should be $null
    }

}


Disconnect-ArubaCP -noconfirm