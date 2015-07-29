#!/bin/bash 
# DR #4360 - this update script will alter the dataURI columns from bufrmthdw

PSQL="/awips2/psql/bin/psql"

cmdDir=`dirname $0`

source ${cmdDir}/commonFunctions.sh
table=bufrmthdw

# table and constraint names from BufrMTHDWObs.
echo "INFO: Start update of ${table} dataURI columns."

col=pressure
echo "INFO: Update ${table}'s ${col}"
# The IDecoderConstants.VAL_MISSING used by MTHDWDataAdapter.
${PSQL} -U awips -d metadata -c "UPDATE ${table} SET ${col}=-9999998 where ${col} is NULL ; "
updateNotNullCol ${table} ${col}

col=satType
echo "Info Update ${table}'s ${col}"
${PSQL} -U awips -d metadata -c "DELETE from ${table} where ${col} is NULL ; "
updateNotNullCol ${table} ${col}

echo "INFO: ${table} dataURI columns updated successfully"
