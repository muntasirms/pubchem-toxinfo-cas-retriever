import aiohttp
import asyncio
import pandas as pd
import re

input_csv = "your_input_file.csv"
output_csv = "chemicals_with_ghs.csv"

# PubChem endpoints
PUBCHEM_URL = "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/{}/cids/JSON"
PUBCHEM_BASE_URL = "https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/{}/JSON/?response_type=display&heading=GHS%20Classification"


async def cas_to_cid(session, cas_number: str, retries: int = 3, delay: float = 1.0):
    url = PUBCHEM_URL.format(cas_number)
    for attempt in range(retries):
        try:
            async with session.get(url, timeout=10) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    if "IdentifierList" in data and "CID" in data["IdentifierList"]:
                        return data["IdentifierList"]["CID"][0]
                    else:
                        return None
                elif resp.status == 404:
                    return None
                elif resp.status == 503:
                    print(f"503 Service Unavailable for CAS {cas_number}, retrying...")
        except Exception as e:
            print(f"Exception for CAS {cas_number}: {e}")
        await asyncio.sleep(delay)
    return None


async def get_ghs_classification(session, cid: int, retries: int = 3, delay: float = 1.0):
    url = PUBCHEM_BASE_URL.format(cid)
    for attempt in range(retries):
        try:
            async with session.get(url, timeout=10) as resp:
                if resp.status == 200:
                    text = await resp.text()
                    # Check for "No data found"
                    if "No data found" in text:
                        return "No data found", "No data found"
                    hazards = re.findall(r"H\d{3}", text)
                    precautions = re.findall(r"P\d{3}", text)
                    return ",".join(sorted(set(hazards))), ",".join(sorted(set(precautions)))
                elif resp.status == 404:
                    return "", ""
                elif resp.status == 503:
                    print(f"503 Service Unavailable for CID {cid}, retrying...")
        except Exception as e:
            print(f"Exception for CID {cid}: {e}")
        await asyncio.sleep(delay)
    return "", ""


async def process_row(session, idx, cas):
    if not cas or pd.isna(cas):
        return idx, "", ""

    print(f"Processing CAS: {cas} ...")
    cid = await cas_to_cid(session, cas)
    if cid:
        hazards, precautions = await get_ghs_classification(session, cid)
        print(f"  → CID {cid} | Hazards: {hazards} | Precautions: {precautions}")
        return idx, hazards, precautions
    else:
        print(f"  → No PubChem match for CAS {cas}")
        return idx, "No data found", "No data found"


async def main(input_csv, output_csv, batch_size=5, pause=2.0):
    # pubchem only allows ~5 requests per second. Increasing batch size beyond 5 may throw 503 errors
    df = pd.read_csv(input_csv)
    df["Hazards"] = ""
    df["Precautions"] = ""

    async with aiohttp.ClientSession() as session:
        tasks = []
        results = []

        for idx, row in df.iterrows():
            tasks.append(process_row(session, idx, row["CAS"]))

            if len(tasks) >= batch_size:
                batch_results = await asyncio.gather(*tasks)
                results.extend(batch_results)
                tasks = []
                print(f"Batch completed. Sleeping {pause} sec...")
                await asyncio.sleep(pause)

        if tasks:
            batch_results = await asyncio.gather(*tasks)
            results.extend(batch_results)

    for idx, hazards, precautions in results:
        df.at[idx, "Hazards"] = hazards
        df.at[idx, "Precautions"] = precautions

    df.to_csv(output_csv, index=False)
    print(f"\n Dataset written to {output_csv}")


if __name__ == "__main__":

    asyncio.run(main(input_csv, output_csv))
