function toxTable = getToxInfo(casNumbers)
% GETTOXINFO Call Python script to fetch tox info from PubChem and convert JSON to MATLAB table.
%   toxTable = GETTOXINFO(casNumbers) runs the Python script with CAS numbers,
%   reads the output JSON, and converts it to a table. Supports batch via cell array.
%
%   Inputs:
%       casNumbers - String or cell array of CAS numbers (e.g., {'50-00-0', '64-17-5'}).
%
%   Outputs:
%       toxTable   - Table with columns: CAS, PubChemCID, IUPAC, Names (cell),
%                    Synonyms (cell), LiteratureReferences (cell of struct), ToxData (cell of struct), Error.
%
%   Requirements:
%   - MATLAB R2014b+ (uses system, jsondecode, table).
%   - Python 3.x with aiohttp, openpyxl (as per script).
%   - Python script 'get_toxinfo_by_cas6.py' in current directory or PATH.
%
%   Usage:
%   toxTable = getToxInfo('50-00-0');  % Single
%   toxTable = getToxInfo({'50-00-0', '64-17-5'});  % Batch
%
%   Notes:
%   - Python script saves to 'tox_data.json' and '.xlsx'; this reads JSON.
%   - Overwrites files; run in dir where that's OK.
%   - For large batches, add pauses to respect API limits.
%   - Nested fields in cell columns.
%   - SMILES skipped; Error column for failures ('N/A' for other fields if error).
%
%   Author: glsalierno
%   Date: September 2025

% Ensure casNumbers is cell array
if ~iscell(casNumbers)
    casNumbers = {casNumbers};
end

% Build command: python script.py CAS1 CAS2 ...
cmd = 'python get_toxinfo_by_cas6.py';
for i = 1:length(casNumbers)
    cmd = sprintf('%s "%s"', cmd, casNumbers{i});
end

% Call Python script
[status, output] = system(cmd);

if status ~= 0
    error('Error calling Python script: %s', output);
end

% Read output JSON
jsonFile = 'tox_data.json';
if ~exist(jsonFile, 'file')
    error('Output JSON file not found: %s', jsonFile);
end

try
    toxStruct = jsondecode(fileread(jsonFile));
catch e
    error('Error parsing JSON: %s', e.message);
end

% Preallocate cell arrays for table columns
n = length(toxStruct);
CAS = cell(n,1);
PubChemCID = cell(n,1);
IUPAC = cell(n,1);
Names = cell(n,1);
Synonyms = cell(n,1);
LiteratureReferences = cell(n,1);
ToxData = cell(n,1);
ErrorMsg = cell(n,1);

% Loop to extract fields, handling errors/dissimilar structs
for j = 1:n
    s = toxStruct(j);
    if isfield(s, 'error')
        CAS{j} = getfield(s, 'CAS', 'N/A');
        PubChemCID{j} = 'N/A';
        IUPAC{j} = 'N/A';
        Names{j} = {};
        Synonyms{j} = {};
        LiteratureReferences{j} = struct();
        ToxData{j} = struct();
        ErrorMsg{j} = s.error;
    else
        CAS{j} = s.CAS;
        PubChemCID{j} = s.PubChemCID;
        IUPAC{j} = s.IUPAC;
        Names{j} = s.Names;
        Synonyms{j} = s.Synonyms;
        LiteratureReferences{j} = s.LiteratureReferences;
        ToxData{j} = s.ToxData;
        ErrorMsg{j} = '';
    end
end

% Create table
toxTable = table(CAS, PubChemCID, IUPAC, Names, Synonyms, LiteratureReferences, ToxData, ErrorMsg, ...
    'VariableNames', {'CAS', 'PubChemCID', 'IUPAC', 'Names', 'Synonyms', 'LiteratureReferences', 'ToxData', 'Error'});

% Display summary
fprintf('Processed %d compounds. Table has %d rows.\n', length(casNumbers), height(toxTable));

end
