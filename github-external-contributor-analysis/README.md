In [A Portrait of VSCode's external contributors](https://steampipe.io/blog/vscode-analysis) we analyzed internal vs external contributors to VSCode using the `vscode.sql` script here. 

You can run `build-the-script.py` with other settings to analyze another repo. The example provided is for TypeScript (`typescript.sql`), where we found:

```
select count(*), 'internal' as type from typescript_internal_committers 
union 
select count(*), 'external' as type from typescript_external_committers;

 count |   type
-------+----------
    54 | internal
   540 | external

select count(*), 'internal' as type from typescript_internal_issue_filers 
union 
select count(*), 'external' as type from typescript_external_issue_filers;

 count |   type
-------+----------
   118 | internal
 10670 | external

select * from typescript_internal_commit_counts limit 10;

 repository_full_name |   author_login    | count
----------------------+-------------------+-------
 microsoft/typescript | ahejlsberg        |  3690
 microsoft/typescript | sheetalkamat      |  2600
 microsoft/typescript | DanielRosenwasser |  2269
 microsoft/typescript | sandersn          |  2209
 microsoft/typescript | andy-ms           |  2067
 microsoft/typescript | rbuckton          |  1708
 microsoft/typescript | weswigham         |  1503
 microsoft/typescript | RyanCavanaugh     |   915
 microsoft/typescript | typescript-bot    |   468
 microsoft/typescript | amcasey           |   466

select * from typescript_external_commit_counts limit 10;

 repository_full_name |  author_login   | count
----------------------+-----------------+-------
 microsoft/typescript | JsonFreeman     |   674
 microsoft/typescript | a-tarasyuk      |   508
 microsoft/typescript | zhengbli        |   468
 microsoft/typescript | yuit            |   217
 microsoft/typescript | saschanaz       |   215
 microsoft/typescript | Kingwl          |   202
 microsoft/typescript | ajafff          |   180
 microsoft/typescript | tinganho        |    99
 microsoft/typescript | JoshuaKGoldberg |    87
 microsoft/typescript | bigaru          |    77

 select * from typescript_internal_issue_counts limit 10;
 
 repository_full_name |   author_login    | count
----------------------+-------------------+-------
 microsoft/typescript | danielrosenwasser |  1192
 microsoft/typescript | ryancavanaugh     |   318
 microsoft/typescript | sandersn          |   296
 microsoft/typescript | dbaeumer          |   249
 microsoft/typescript | weswigham         |   199
 microsoft/typescript | amcasey           |   139
 microsoft/typescript | rbuckton          |   106
 microsoft/typescript | egamma            |    96
 microsoft/typescript | sheetalkamat      |    69
 microsoft/typescript | jrieken           |    60

 select * from typescript_external_issue_counts limit 10;
 
 repository_full_name |   author_login   | count
----------------------+------------------+-------
 microsoft/typescript | falsandtru       |   439
 microsoft/typescript | zpdDG4gta8XKpMCd |   310
 microsoft/typescript | OliverJAsh       |   245
 microsoft/typescript | ajafff           |   220
 microsoft/typescript | JsonFreeman      |   156
 microsoft/typescript | tinganho         |   151
 microsoft/typescript | saschanaz        |   133
 microsoft/typescript | basarat          |   130
 microsoft/typescript | NoelAbrahams     |   129
 microsoft/typescript | yuit             |   116


```