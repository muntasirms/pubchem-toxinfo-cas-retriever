function toxTable = getToxInfo(casNumbers)
% GETTOXINFO Call Python script to fetch tox info from PubChem and convert JSON to MATLAB table.
%   toxTable = GETTOXINFO(casNumbers) runs the Python script with CAS numbers,
%   reads the output JSON, and converts it to a table. Supports batch via cell array.
%
%   Inputs:
%       casNumbers - String or cell array of CAS numbers (e.g., {'50-00-0', '64-17-5'}).
%
%   Outputs:
%       toxTable   - Table with columns: CAS, PubChemCID, IUPAC, SMILES, Names (cell),
%                    Synonyms (cell), LiteratureReferences (struct), ToxData (struct).
%
%   Requirements:
%   - MATLAB R2014b+ (uses system, jsondecode, struct2table).
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
%   - Nested fields (e.g., ToxData) remain structs/cells in table.
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

% Convert struct array to table
if isstruct(toxStruct)
    toxTable = struct2table(toxStruct, 'AsArray', true);
else
    toxTable = table();
end

% Display summary
fprintf('Processed %d compounds. Table has %d rows.\n', length(casNumbers), height(toxTable));

end
