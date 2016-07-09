﻿# ---------------------------------------------------------------------------
# Download the published content from the FHIR specification
# ---------------------------------------------------------------------------
# cls

# Script to be run from 'build' directory

$server = "http://hl7-fhir.github.io";
# $server = "http://hl7.org/fhir/2016May";
$baseDir = Resolve-Path ..
$srcdir = "$baseDir\src";

# Download a file from a URL and place it at the specified target path.
# This also has some basic capabilities to go through proxies without any additional configuration.
function PowerCurl($targetPath, $sourceUrl)
{
	Try
	{
		Write-Host -ForegroundColor White "downloading $sourceUrl to $targetPath ..."
        $webclient = New-Object System.Net.WebClient
        $webclient.DownloadFile($sourceUrl, $targetPath)
	} Catch
	{
		Write-Host -ForegroundColor Red "$_ occurred while downloading $sourceUrl to $targetPath"
		$_ | fl * -Force
	}
}


# Download the core profiles for code generation
PowerCurl "$srcdir\Hl7.Fhir.Core\Model\Source\expansions.xml" "$server/expansions.xml"
PowerCurl "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-resources.xml" "$server/profiles-resources.xml"
PowerCurl "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-types.xml" "$server/profiles-types.xml"
PowerCurl "$srcdir\Hl7.Fhir.Core\Model\Source\search-parameters.xml" "$server/search-parameters.xml"

PowerCurl "$srcdir\Hl7.Fhir.Core.Tests\TestData\careplan-example-f201-renal.xml" "$server/careplan-example-f201-renal.xml"
PowerCurl "$srcdir\Hl7.Fhir.Core.Tests\TestData\examples.zip" "$server/examples.zip"
PowerCurl "$srcdir\Hl7.Fhir.Core.Tests\TestData\examples-json.zip" "$server/examples-json.zip"
PowerCurl "$srcdir\Hl7.Fhir.Core.Tests\TestData\json-edge-cases.json" "$server/json-edge-cases.json"

PowerCurl "$srcdir\Hl7.Fhir.Specification\validation.xml.zip" "$server/definitions.xml.zip"
PowerCurl "$srcdir\Hl7.Fhir.Specification.Tests\TestData\snapshot-test\profiles-others.xml" "$server/profiles-others.xml"
copy "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-resources.xml" "$srcdir\Hl7.Fhir.Specification.Tests\TestData\snapshot-test"
copy "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-types.xml" "$srcdir\Hl7.Fhir.Specification.Tests\TestData\snapshot-test"

# Apply this transform to remove all the Meta sections from the profiles (to remove the LastUpdated tags) 
# this makes it easier to see the actual changes between versions
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
$xslt.Load("$baseDir\Build\StripLastModified.xslt");

Write-Host -ForegroundColor White "transforming profiles-resources.xml ..."
$xslt.Transform("$srcdir\Hl7.Fhir.Core\Model\Source\profiles-resources.xml", "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-resources2.xml");
del "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-resources.xml"
move "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-resources2.xml" "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-resources.xml"

Write-Host -ForegroundColor White "transforming profiles-types.xml ..."
$xslt.Transform("$srcdir\Hl7.Fhir.Core\Model\Source\profiles-types.xml", "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-types2.xml");
del "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-types.xml"
move "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-types2.xml" "$srcdir\Hl7.Fhir.Core\Model\Source\profiles-types.xml"

Write-Host -ForegroundColor White "transforming search-parameters.xml ..."
$xslt.Transform("$srcdir\Hl7.Fhir.Core\Model\Source\search-parameters.xml", "$srcdir\Hl7.Fhir.Core\Model\Source\search-parameters2.xml");
del "$srcdir\Hl7.Fhir.Core\Model\Source\search-parameters.xml"
move "$srcdir\Hl7.Fhir.Core\Model\Source\search-parameters2.xml" "$srcdir\Hl7.Fhir.Core\Model\Source\search-parameters.xml"