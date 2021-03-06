#Uncomment to select which version of Studio you are using
#param([String]$StudioVersion = "Studio4")
param([String]$StudioVersion = "Studio5")

if ("${Env:ProgramFiles(x86)}") {
    $ProgramFilesDir = "${Env:ProgramFiles(x86)}"
}
else {
    $ProgramFilesDir = "${Env:ProgramFiles}"
}

Add-Type -Path "$ProgramFilesDir\SDL\SDL Trados Studio\$StudioVersion\Sdl.ProjectAutomation.FileBased.dll"
Add-Type -Path "$ProgramFilesDir\SDL\SDL Trados Studio\$StudioVersion\Sdl.ProjectAutomation.Core.dll"

function New-Package
{
	param([Sdl.Core.Globalization.Language] $language,[String] $packagePath,
	[Sdl.ProjectAutomation.FileBased.FileBasedProject]$projectToProcess)
	
	$today = Get-Date;
	[Sdl.ProjectAutomation.Core.TaskFileInfo[]] $taskFiles =  Get-TaskFileInfoFiles $language $projectToProcess;
	[Sdl.ProjectAutomation.Core.ManualTask] $task = $projectToProcess.CreateManualTask("Translate", "API translator", $today +1 ,$taskFiles);
	[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions = Get-PackageOptions
	[Sdl.ProjectAutomation.Core.ProjectPackageCreation] $package = $projectToProcess.CreateProjectPackage($task.Id, "mypackage",
                "A package created by the API", $packageOptions);
	$projectToProcess.SavePackageAs($package.PackageId, $packagePath);
}

function Get-PackageOptions
{
	[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions = New-Object Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions;
	$packageOptions.IncludeAutoSuggestDictionaries = $false;
	$packageOptions.IncludeMainTranslationMemories = $false;
    $packageOptions.IncludeTermbases = $false;
    $packageOptions.ProjectTranslationMemoryOptions = [Sdl.ProjectAutomation.Core.ProjectTranslationMemoryPackageOptions]::UseExisting;
    $packageOptions.RecomputeAnalysisStatistics = $false;
    $packageOptions.RemoveAutomatedTranslationProviders = $true;
    return $packageOptions;
}



Export-ModuleMember New-Package;



