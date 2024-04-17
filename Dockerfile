# build react app
#At time of writing, node lts (18) produces corrupt tarballs. Attempts to fix this include trying lts-alpine and setting the locale manually.
FROM node:16
ARG VERSION
ARG PUBLISH_FEED
ARG PRERELEASE=FALSE
ARG AUTHTOKEN

# build .npmrc
RUN echo "@ametektci:registry=$PUBLISH_FEED\n//npm.pkg.github.com/:_authToken=$AuthToken\n" > ./.npmrc

# copy react files
COPY src/ ./src
COPY package.json ./
COPY package-lock.json ./
COPY jest.config.ts ./
COPY tsconfig.json ./tsconfig.json

# install npm dependencies
RUN npm install

# update the package version
RUN if [ "$PRERELEASE" = "TRUE" ]; then npm version "$VERSION" --preid=dev --no-git-tag-version; else npm version "$VERSION" --no-git-tag-version; fi;

RUN npm run prepublishOnly
#Requires type: Module, which breaks the json import.
#RUN npm run test
# publish to the package feed
RUN npm publish --registry "$PUBLISH_FEED"

