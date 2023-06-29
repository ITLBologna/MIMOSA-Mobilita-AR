![banner](resources/banner.png)

## MIMOSA Mobilità AR

This repository contains the open source code developed by [Fondazione ITL](https://www.fondazioneitl.org/) for the MIMOSA augmented-reality InfoMobility application related to the project ["Maritime and MultimOdal Sustainable pAssenger transport solutions and services"](https://www.fondazioneitl.org/en/project/mimosa-maritime-and-multimodal-sustainable-passenger-transport-solutions-and-services/) (MIMOSA).

This Mimosa Mobilità AR action is related to the development of both cloud/server infrastructure and mobile application front-end for the augmented reality infomobility application.

### Cloud Environment (low load, pilot project)

Here is the technical description of the virtual machine cloud instances deployed for the core MIMOSA services, dimensioned for the Pilot Project which should handle from 100 to 1000 active users

**Amazon AWS Instances**
- 5 VM EC2, tu O.S. Ubuntu 22.04 LTS
  -	Mimosa Production (r6g.medium, EBS 16Gb)
  - Mimosa Development (r6g.medium, EBS 16Gb)
  - Mimosa OTP (OpenTripPlanner, r6g.medium, EBS 16Gb)
  - Mimosa Analytics (Matomo, t4g.small, EBS 50Gb)
  - Mimosa Pelias (Pelias, c6i.large, EBS 24Gb)


### Installation Guides
- Server Administration [guide](admin/README.md)
- ETL Environment [guide](etl/README.md)


### Acknowledgment

MIMOSA Mobilità AR has been part of the [MIMOSA](https://www.fondazioneitl.org/en/project/mimosa-maritime-and-multimodal-sustainable-passenger-transport-solutions-and-services/)
