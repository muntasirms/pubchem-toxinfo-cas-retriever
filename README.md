# PubChem Toxicological Info Retriever by CAS

Asynchronous Python script to retrieve toxicological information, IUPAC names, SMILES, synonyms, names, and literature references from PubChem for CAS numbers using PUG REST API. Exports to JSON/Excel.

## Files
- `get_toxinfo_by_cas.py`: Main Python script for fetching and exporting data.

## Requirements
- **Python 3.x**: With `aiohttp` (`pip install aiohttp`), `openpyxl` (`pip install openpyxl`).

## Usage
Run the script with CAS numbers as arguments for batch processing:'

> python get_toxinfo_by_cas.py 50-00-0 64-17-5

>Fetching data for 2 CAS numbers...

>Processing CAS 50-00-0

>Processing CAS 64-17-5

>Found CID 712 for CAS 50-00-0

>Found CID 702 for CAS 64-17-5

>Data for 2 compounds saved to tox_data.json

>Data exported to Excel file: tox_data.xlsx

>Please check the JSON and Excel files for the retrieved data.

Or run without arguments for interactive input (enter CAS one per line, blank to finish).

## Notes
- Complies with PubChem API terms (add pauses for large batches).
- Handles retries for transient errors.
- For issues, open a GitHub issue.

Author: glsalierno  
Date: September 2025  
GitHub: [glsalierno](https://github.com/glsalierno)
