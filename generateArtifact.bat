:: clean up
rmdir dist /s /q
mkdir dist
:: requires 7zip
7za a dist/Broker_CTA Broker_CTA -tzip
