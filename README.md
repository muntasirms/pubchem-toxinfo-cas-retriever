[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/glsalierno/pubchem-toxinfo-cas-retriever/blob/main/LICENSE)
[![Python 3.x](https://img.shields.io/badge/python-3.x-blue.svg)](https://www.python.org/downloads/)

# PubChem Toxicological Info Retriever by CAS

Asynchronous Python script to retrieve toxicological information, IUPAC names, SMILES, synonyms, names, and literature references from PubChem for CAS numbers using PUG REST API. Exports to JSON/Excel.

## Key Features
- Asynchronous fetching for efficient batch processing.
- Extracts tox data, IUPAC/SMILES, synonyms, and literature refs.
- Handles retries for API errors; exports to formatted JSON and Excel.
- Interactive or command-line input.

## Requirements
- Python 3.x
- Install dependencies: `pip install aiohttp openpyxl`

## Usage
Run with CAS numbers for batch processing:

> > python get_toxinfo_by_cas6.py 50-00-0 64-17-5

>Fetching data for 2 CAS numbers...

>Processing CAS 50-00-0

>Processing CAS 64-17-5

>Found CID 712 for CAS 50-00-0

>Found CID 702 for CAS 64-17-5

>Data for 2 compounds saved to tox_data.json

>Data exported to Excel file: tox_data.xlsx

>Please check the JSON and Excel files for the retrieved data.

Or run without arguments for interactive mode (enter CAS one per line, blank to finish).

## Files
- `get_toxinfo_by_cas6.py`: Main script for data retrieval and export.
- getToxInfo.m: MATLAB wrapper function.

## Contributing
Fork the repo, create a feature branch, and submit a pull request. Follow PEP8 style. Report issues via GitHub Issues.

## Notes
- Complies with PubChem API terms (add pauses for large batches).
- Handles retries for transient errors.
- For issues, open a GitHub issue.

### MATLAB
The MATLAB wrapper calls the Python script and parses the JSON output into a table:

```matlab
toxTable = getToxInfo({'50-00-0', '64-17-5'});
% Outputs a table with tox data; Python script runs in background.



Author: glsalierno  
Date: September 2025  
GitHub: [glsalierno](https://github.com/glsalierno)
