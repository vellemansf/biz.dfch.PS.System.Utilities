﻿
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Test-Get-Priority" "Test-Get-Priority" {

	Mock Export-ModuleMember { return $null; }

	. "$here\$sut"

	Context "Test-CmdletExists" {

		It "GettingHelp-ShouldSucceed" {
			# Act / Assert
			Get-Help Get-Priority | Should Not Be $Null;
		}
    }

	Context "Test-InvalidInput" {

		It "InvalidInput-ShouldThrow" {
			# Act / Assert
			{ Get-Priority -Id -1 } | Should Throw;
			{ Get-Priority -Id 0 } | Should Throw;
			{ Get-Priority -Id "some bogus string" } | Should Throw;
			{ Get-Priority -Id [String]::Empty } | Should Throw;
			{ Get-Priority -Id $null } | Should Throw;
		}

		It "NonExistentProcess-ShouldThrow" {
			# Arrange
			$processId = 42;
			$exMessage = 'Get-Process : Cannot find a process with the name "{0}". Verify the process name and call the cmdlet again.' -f $processId;
			Mock Get-Process {
				$ex = New-Object Microsoft.PowerShell.Commands.ProcessCommandException($exMessage);
				throw $ex;
			}

			# Act / Assert
			{ Get-Priority -Id $processId } | Should Throw;
			Assert-MockCalled Get-Process -Exactly 1 -Scope It;
		}
    }

	Context "Test-ValidInput" {

		It "CurrentPriority-ShouldBeNormal" {

			# Arrange
			$expectedResult = 'anyPriorityClass';
			Mock Get-Process {
				return @{ PriorityClass = $expectedResult; }
			}

			# Act 
			$result = Get-Priority 

			# Assert
			Assert-MockCalled Get-Process -Exactly 1 -Scope It;
			$result -is [String] | Should Be $true;
			$result | Should Be $expectedResult;
		}
		It "Pipeline-ShouldBeNormal" {

			# Arrange
			$expectedResult = 'anyPriorityClass';
			Mock Get-Process {
				return @{ PriorityClass = $expectedResult; }
			}

			# Act 
			$result = 42, 43, 44 | Get-Priority 

			# Assert
			Assert-MockCalled Get-Process -Exactly 3 -Scope It;
			$result -is [Array] | Should Be $true;
			$result.Count | Should Be 3;
			$result[0] | Should Be $expectedResult;
			$result[1] | Should Be $expectedResult;
			$result[2] | Should Be $expectedResult;
		}
		It "Array-ShouldBeNormal" {

			# Arrange
			$expectedResult = 'anyPriorityClass';
			Mock Get-Process {
				return @{ PriorityClass = $expectedResult; }
			}

			# Act 
			$result = Get-Priority @(42, 43, 44)

			# Assert
			Assert-MockCalled Get-Process -Exactly 3 -Scope It;
			$result -is [Array] | Should Be $true;
			$result.Count | Should Be 3;
			$result[0] | Should Be $expectedResult;
			$result[1] | Should Be $expectedResult;
			$result[2] | Should Be $expectedResult;
		}
    }
}

##
 #
 #
 # Copyright 2015 Ronald Rink, d-fens GmbH
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 # http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #
 #

