# seqtk-gui
Rshiny app for fastq to fasta conversion using seqtk. This is a dry run for giving commandline tools a GUI.

# Installation
```
docker build -t seqtk-gui:local .
docker run -d --name seqtk-gui -p 8080:3838 seqtk-gui:local
```

# Instructions
Upload a .fastq file and the app will convert it to a .fasta file. You can then downloaded the .fasta conversion.
