#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Endpoint" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 -description "Add by PowerArubaCP for Pester" -status Known
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:06 -description "Add by PowerArubaCP for Pester" -status Unknown
    }

    It "Get Endpoint Does not throw an error" {
        {
            Get-ArubaCPEndpoint
        } | Should Not Throw
    }

    It "Get ALL Endpoint" {
        $ep = Get-ArubaCPEndpoint
        $ep.count | Should not be $NULL
    }

    It "Get Endpoint (00:01:02:03:04:05)" {
        $ep = Get-ArubaCPEndpoint | Where-Object { $_.mac_address -eq "000102030405" }
        $ep.id | Should not be BeNullOrEmpty
        $ep.mac_address | Should be "000102030405"
        $ep.description | Should be "Add by PowerArubaCP for Pester"
        $ep.status | Should be "Known"
    }

    It "Get Endpoint (00:01:02:03:04:06) and confirm (via Confirm-ArubaCPEndpoint)" {
        $ep = Get-ArubaCPEndpoint | Where-Object { $_.mac_address -eq "000102030406" }
        Confirm-ArubaCPEndpoint $ep | Should be $true
    }

    It "Search Endpoint by name (000102030405)" {
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        @($ep).count | Should be 1
        $ep.id | Should not be BeNullOrEmpty
        $ep.mac_address | Should be "000102030405"
        $ep.description | Should be "Add by PowerArubaCP for Pester"
    }

    It "Search Endpoint by description (contains * 00:01:02:03:04*)" {
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04 -filter_type contains
        @($ep).count | Should be 2
    }

    It "Search Endpoint by attribute (description contains *pester*)" {
        $ep = Get-ArubaCPEndpoint -filter_attribute description -filter_type contains -filter_value pester
        @($ep).count | Should be 2
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Remove-ArubaCPEndpoint -noconfirm
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:06 | Remove-ArubaCPEndpoint -noconfirm
    }
}

Describe  "Add Endpoint" {

    It "Add Endpoint with Known Status" {
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 -status Known
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        $ep.id | Should not be BeNullOrEmpty
        $ep.mac_address | Should be "000102030405"
        $ep.status | Should be "Known"
        $ep.attributes | Should be ""
    }

    It "Add Endpoint with Unknown Status and description" {
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 -Status Unknown -description "Add By PowerArubaCP"
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        $ep.id | Should not be BeNullOrEmpty
        $ep.mac_address | Should be "000102030405"
        $ep.status | Should be "Unknown"
        $ep.description | Should be "Add By PowerArubaCP"
        $ep.attributes | Should be ""
    }

    It "Add Endpoint with Disable Status and an attribute" {
        $attributes = @{"Disabled by" = "PowerArubaCP" }
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 -Status Disabled -attributes $attributes
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        $ep.id | Should not be BeNullOrEmpty
        $ep.mac_address | Should be "000102030405"
        $ep.status | Should be "Disabled"
        $ep.attributes.'Disabled by' | Should be "PowerArubaCP"
    }

    AfterEach {
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Remove-ArubaCPEndpoint -noconfirm
    }
}

Describe  "Configure Endpoint" {
    BeforeEach {
        #Add 1 entry
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 -status Known
    }

    It "Change Status Endpoint (Known => Unknown) and description" {
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Set-ArubaCPEndpoint -status "Unknown" -description "Modified by PowerArubaCP"
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        $ep.id | Should not be BeNullOrEmpty
        $ep.mac_address | Should be "000102030405"
        $ep.status | Should be "Unknown"
        $ep.description | Should be "Modified by PowerArubaCP"
        $ep.attributes | Should be ""
    }

    It "Change status Endpoint (Known => Disabled) and attributes" {
        $attributes = @{"Disabled by" = "PowerArubaCP" }
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Set-ArubaCPEndpoint -status "Disabled" -attributes $attributes
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        $ep.id | Should not be BeNullOrEmpty
        $ep.mac_address | Should be "000102030405"
        $ep.status | Should be "Disabled"
        $ep.attributes.'disabled by' | Should be "PowerArubaCP"
    }

    It "Change MAC Address Endpoint" {
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Set-ArubaCPEndpoint -mac_address 00:01:02:03:04:06
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:06
        $ep.id | Should not be BeNullOrEmpty
        $ep.mac_address | Should be "000102030406"
        $ep.status | Should be "Known"
        $ep.attributes | Should be ""
    }

    AfterEach {
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Remove-ArubaCPEndpoint -noconfirm
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:06 | Remove-ArubaCPEndpoint -noconfirm
    }
}
Describe  "Remove Endpoint" {

    It "Remove Endpoint by id" {
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 -status Unknown
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        $ep.mac_address | Should be "000102030405"
        @($ep).count | should be 1
        Remove-ArubaCPEndpoint -id $ep.id -noconfirm
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        $ep | Should BeNullOrEmpty
        @($ep).count | should be 0
    }

    It "Remove Endpoint by name (and pipeline)" {
        Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 -status Unknown
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        $ep.mac_address | Should be "000102030405"
        @($ep).count | should be 1
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Remove-ArubaCPEndpoint -noconfirm
        $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
        $ep | Should BeNullOrEmpty
        @($ep).count | should be 0
    }

    AfterEach {
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Remove-ArubaCPEndpoint -noconfirm
    }
}

Disconnect-ArubaCP -noconfirm