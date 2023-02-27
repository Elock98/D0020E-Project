# D0020E-Project

## Setup Environment

Follow the link below to set up pre requirements:
[Fabric prereqs](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html)

Then set up the environment by running the script setupEnv.sh 
```
cd src
./setupEnv.sh
```

## Network setup

```
cd network
./setup.sh
```

When running setup the default number of organizations is 2, to specify how many run the following:
(Example, setup for 4 orgs)
```
./setup.sh -o 4
``` 

## Start the Network

You can run the following to deploy the network

### Fast start

(Example, start for 4 orgs)
```
./fast-start.sh 4
```

The number of orgs must be the same for both network setup and network start
