[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/glsalierno/pubchem-toxinfo-cas-retriever/blob/main/LICENSE)
[![Python 3.x](https://img.shields.io/badge/python-3.x-blue.svg)](https://www.python.org/downloads/)

# PubChem Toxicological Info Retriever by CAS

Fork of @glsalierno 's pubchem toxicity info scraper. This fork retains the asyncronous API calls but focuses solely on extracting H-code hazard statements and P-code precautionary statements into two new comma delimited columns of each for future programmatic screening of chemical safety.

## New features
- Removed openpyxl in favor of pandas only csv handling
- Retained asyncio asynchronous fetching, but added the ability to define batch size
- Denotes chemicals with lack of hazard information with "No data found"
- Removed matlab functionality

## Retained Key Features
- Asynchronous fetching for efficient batch processing
- Extracts tox data
- Handles retries for API (CID retrieval) errors; exports to identical csv with two additional column .

## Requirements
- Python 3.x
- Install dependencies: `pip install aiohttp pandas`

## Usage
Input CSV with a column named "CAS" and input csv filepath and output filepath:

```python
input_csv = "yourChemicalInputs.csv"
output_csv = "chemicals_with_ghs.csv"
```

Example input CSV format should be:

| Name          | CAS        | Other Data      | ... |
|---------------|------------|----------------|-----|
| Acetone       | 67-64-1    | Example info   | ... |
| Ethanol       | 64-17-5    | Example info   | ... |


and output format will be:

| Name          | CAS        | Other Data      | ... | Hazards | Precautions |
|---------------|------------|----------------|-----|------|-------|
| Acetone       | 67-64-1    | Example info   | ... | H225, H319, H336 | P210, P240, P233, P241...|
| Ethanol       | 64-17-5    | Example info   | ... | H225, H319 | P210, P233, P240, ... |





