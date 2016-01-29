dir "D:\myStackOps\Datacenters\lo1" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\lo1 -force
dir "D:\myStackOps\Datacenters\lo3" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\lo3 -force
dir "D:\myStackOps\Datacenters\icd" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\icd -force
dir "D:\myStackOps\Datacenters\nj2" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\nj2 -force
dir "D:\myStackOps\Datacenters\sg8" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\sg8 -force
dir "D:\myStackOps\Datacenters\bj1" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\bj1 -force
dir "D:\myStackOps\Datacenters\au1" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\au1 -force
dir "D:\myStackOps\Datacenters\sh1" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\sh1 -force
dir "D:\myStackOps\Datacenters\bz1" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\bz1 -force

dir "D:\myStackOps\Datacenters\lo1\TSM-BACKUPs" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\lo1\TSM-BACKUPs -force
dir "D:\myStackOps\Datacenters\lo3\TSM-BACKUPs" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\lo3\TSM-BACKUPs -force
dir "D:\myStackOps\Datacenters\icd\TSM-BACKUPs" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\icd\TSM-BACKUPs -force
dir "D:\myStackOps\Datacenters\nj2\TSM-BACKUPs" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\nj2\TSM-BACKUPs -force
dir "D:\myStackOps\Datacenters\sg8\TSM-BACKUPs" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\sg8\TSM-BACKUPs -force
dir "D:\myStackOps\Datacenters\bj1\TSM-BACKUPs" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\bj1\TSM-BACKUPs -force
dir "D:\myStackOps\Datacenters\au1\TSM-BACKUPs" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\au1\TSM-BACKUPs -force
dir "D:\myStackOps\Datacenters\sh1\TSM-BACKUPs" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\sh1\TSM-BACKUPs -force
dir "D:\myStackOps\Datacenters\bz1\TSM-BACKUPs" | where { ((get-date)-$_.creationTime).days -gt 4} | move-item -destination D:\myStackOps\Archive\bz1\TSM-BACKUPs -force


dir "D:\myStackOps\Archive" recurse | where { ((get-date)-$_.creationTime).days -gt 30 } | remove-item -force
 