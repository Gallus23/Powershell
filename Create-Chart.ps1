<#
Need to create Hash Table of data to feed this function. E.g.

$Datastores = Get-Datastore | Select Name, CapacityGB
$HT = @{}
foreach ($ds in $Datastores) {
	$HT.Add($ds.Name,$ds.CapacityGB)
}

$VMs = Get-VM
$HT = @{}
foreach ($vm in $VMs) {
	$HT.Add($vm.Name,$vm.NumCpu)
}

Example of using the function:

Create-Chart -ChartType pie -ChartTitle "Datastore Capacity (GB)" -FileName ds-capacity -XAxisName GB -YAxisName "Datastore Names" -ChartWidth 800 -ChartHeight 800 -DataHashTable $HT

#>

Function Create-Chart() {
	
	Param(
	    [String]$ChartType,
		[String]$ChartTitle,
	    [String]$FileName,
		[String]$XAxisName,
	    [String]$YAxisName,
		[Int]$ChartWidth,
		[Int]$ChartHeight,
		[HashTable]$DataHashTable
	)
		
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
	
	#Create our chart object 
	$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
	$Chart.Width = $ChartWidth
	$Chart.Height = $ChartHeight
	$Chart.Left = 10
	$Chart.Top = 10

	#Create a chartarea to draw on and add this to the chart 
	$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
	$Chart.ChartAreas.Add($ChartArea) 
	[void]$Chart.Series.Add("Data") 

	$Chart.ChartAreas[0].AxisX.Interval = "1" #Set this to 1 (default is auto) and allows all X Axis values to display correctly
	$Chart.ChartAreas[0].AxisX.IsLabelAutoFit = $false;
	$Chart.ChartAreas[0].AxisX.LabelStyle.Angle = "-45"
	
	#Add the Actual Data to our Chart
	$Chart.Series["Data"].Points.DataBindXY($DataHashTable.Keys, $DataHashTable.Values)

	if (($ChartType -eq "Pie") -or ($ChartType -eq "pie")) {
		$ChartArea.AxisX.Title = $XAxisName
		$ChartArea.AxisY.Title = $YAxisName
		$Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Pie
		$Chart.Series["Data"]["PieLabelStyle"] = "Outside" 
		$Chart.Series["Data"]["PieLineColor"] = "Black" 
		$Chart.Series["Data"]["PieDrawingStyle"] = "Concave" 
		($Chart.Series["Data"].Points.FindMaxByValue())["Exploded"] = $true
		$Chart.Series["Data"].Label = "#VALX = #VALY\n" # Give an X & Y Label to the data in the plot area (useful for Pie graph) (Display both axis labels, use: Y = #VALY\nX = #VALX)
	}
	
	elseif (($ChartType -eq "Bar") -or ($ChartType -eq "bar")) {
		#$Chart.Series["Data"].Sort([System.Windows.Forms.DataVisualization.Charting.PointSortOrder]::Descending, "Y")
		$ChartArea.AxisX.Title = $XAxisName
		$ChartArea.AxisY.Title = $YAxisName
		# Find point with max/min values and change their colour
		$maxValuePoint = $Chart.Series["Data"].Points.FindMaxByValue()
		$maxValuePoint.Color = [System.Drawing.Color]::Red
		$minValuePoint = $Chart.Series["Data"].Points.FindMinByValue()
		$minValuePoint.Color = [System.Drawing.Color]::Green
		# make bars into 3d cylinders
		$Chart.Series["Data"]["DrawingStyle"] = "Cylinder"
		$Chart.Series["Data"].Label = "#VALY" # Give a Y Label to the data in the plot area (useful for Bar graph)
	}
	
	else {
		Write-Host "No Chart Type was defined. Try again and enter either Pie or Bar for the ChartType Parameter. The chart will be created as a standard Bar Graph Chart for now." -ForegroundColor Cyan
	}

	#Set the title of the Chart to the current date and time 
	$Title = new-object System.Windows.Forms.DataVisualization.Charting.Title 
	$Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
	$ChartTitle.Font =$Font
	$Chart.Titles.Add($Title) 
	$Chart.Titles[0].Text = $ChartTitle

	#Save the chart to a file
	$FullPath = ((Get-Location).Path + "\" + $FileName + ".png")
	$Chart.SaveImage($FullPath,"png")
	Write-Host "Chart saved to $FullPath" -ForegroundColor Green

	return $FullPath

}
