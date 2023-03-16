# Network

## Requirements

 - Unix-based system
 - [Docker](https://www.docker.com/)
 - [Fabric prereqs](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html)
 - [Golang](https://go.dev/doc/install)

## Usage

### Setup Script

The idea behind the script is to generate network config files and scripts for a specified number of organizations with one peer node each.

This is accomplished by mostly reading template files and writing to specified files accordingly.

The script can run by simply running
```
./setup.sh
```
Note that it's defaulted to 2 orgs.

Or you can specify the number of organizations by
```
./setup.sh -o <number>
```

### Network Script

#### Fast start

## Tests

The network has been configured, setup and verified to be working for up to 15
organizations at the same time.

There is also a test script that checks if the setup script generates the expected
outcome for 2 and 4 organizations. This test script is located under the ***src/test/***
directory.

## Potential Risks

One noteworthy potential limitation of the setup script is that some of the ports used are generated with an incremental value of up to 2000 or more. This may result in a shortage in ports when generating ports for large amount of organizations.
