# FHIR Encounter API to Power BI with Azure Data Factory

A hands-on Azure data engineering lab that retrieves synthetic healthcare encounters from a public FHIR R4 API, transforms them in Azure Data Factory, and loads the results into Power BI.

## Architecture

FHIR Encounter API → ADF Copy Data → Raw JSON in Blob Storage → ADF Mapping Data Flow → Processed CSV in Blob Storage → Power BI

## How the pipeline works

| Stage | Implementation |
|---|---|
| Ingestion | `pipeline1` sends an anonymous HTTP `GET` request to a public FHIR Encounter endpoint and saves the response as a JSON file in Azure Blob Storage. |
| Transformation | `pipeline2` runs `dataflow1`. It reads the FHIR Bundle as a single JSON document, flattens the `entry` array into rows, and keeps encounters with `resource.status == 'finished'`. |
| Output | The Data Flow extracts the encounter ID and status and writes them to a CSV in Blob Storage. |
| Reporting | Power BI Desktop connects to Blob Storage and loads the processed CSV through Power Query. |

## Validation and recovery

I used a separate Python script to count the finished encounters in the saved FHIR Bundle. The count matched across all three stages.

| Stage | Count |
|---|---:|
| Finished encounters in the saved JSON | 20 |
| Data rows in the output CSV | 20 |
| Rows loaded into Power BI | 20 |

I reran `pipeline2` using the saved raw JSON. The rerun produced a second CSV with 20 rows without another API request. For a snapshot report, the report should read one intended output file so repeated runs do not inflate the total.

## Troubleshooting

- Resolved a `FAILFAST` JSON parsing error by setting the Data Flow source to **Single document** to match the saved Bundle.
- Resolved a CSV sink validation error by excluding nested fields and mapping only the encounter ID and status.

## Repository structure

| Folder | Contents |
|---|---|
| `pipeline/` | ADF ingestion and transformation pipeline definitions |
| `dataflow/` | Mapping Data Flow definition |
| `dataset/` | Source and sink dataset definitions |
| `linkedService/` | ADF connection definitions |

## Lab scope

The lab processes one saved API response page containing 20 synthetic encounters. A full extraction would follow the FHIR Bundle’s `next` links and reconcile records across pages.

The repository stores ADF configuration. Blob files and the Power BI `.pbix` report are managed separately. Configure Azure connections in your own environment and keep credentials out of source control.
