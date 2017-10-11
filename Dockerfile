FROM spdz/spdz:v0.4.1-analytics-engine

# Compile the analytics mpc programs into a container and setup to be able to start a selected program.
# Note this version of SPDZ does not rely on the server.x coordination startup program.
# Build container with:
#   docker build -t spdz/analytics:va.b.c .
# Run container with:
#   docker run -d --rm --name spdz-analytics-<playerId> --expose 13000 -p 13000:13000 
#          --expose 14000 -p 14000:14000 --env playerId=0 --env basePort=13000 
#          --env mpcPgm=analytics_avg
#          -v <location of Player-Data>:/usr/spdz/Player-Data 
#          -v <location of logs>:/usr/spdz/logs 
#          -v <location of config>:/usr/spdz/HOSTS.config spdz/analytics:va.b.c


LABEL name="SPDZ MPC Analytics" \
  description="Compile analytics functions for use with analytics-engine." \
  maintainer="Jonathan Evans <jon.evans@bristol.ac.uk>" \
  license="University of Bristol : Open Access Software Licence" 

# Optional compiler args e.g. -M
ARG compilerArgs=''

# buildtemp needed because of .dockerignore file for other builds
COPY spdz/Programs/Source/analytics_avg.mpc Programs/Source
COPY spdz/Programs/Source/distrib_percent.mpc Programs/Source
COPY spdz/Programs/Source/sumby_lookup.mpc Programs/Source

RUN ./compile.py $compilerArgs analytics_avg \
  && ./compile.py $compilerArgs distrib_percent \
  && ./compile.py $compilerArgs sumby_lookup

ENV playerId=0
ENV basePort=13000
ENV mpcPgm=

# server ports to listen on depend on player id (14000 + playerId, 13000 + playerId)
# expose at run time with --expose and -p.

# Pass in offline data at run time for specific player 
VOLUME /usr/spdz/Player-Data

# Store logs onto host file system
VOLUME /usr/spdz/logs

# Map to hosts file
VOLUME /usr/spdz/HOSTS.config

ENTRYPOINT exec ./Player-Online.x -lgp 128 -lg2 40 -m empty -ip /usr/spdz/HOSTS.config -pn $basePort $playerId $mpcPgm \
  > /usr/spdz/logs/spdz_player$playerId.log 2>&1
