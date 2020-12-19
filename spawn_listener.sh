#!/bin/bash -x
NC_HOME=/home/vagrant/nc_home
PORT_FILE=${NC_HOME}/nc.port
NEW_PORT_FILE=${NC_HOME}/nc.port.new
SITE_OK_STATUS="200"
PID_FILE=${NC_HOME}/nc.pid
NEW_PID_FILE=${NC_HOME}/nc.pid.new
NC_PID=""
NC_PID_STATUS=""
NC_PORT_OK_STATUS=""
SERVICE_STATUS=""
SERVICE_READY_STATUS=""
NEW_PORT=""
NEW_PID=""
NEW_NC_PORT=""
NEW_SERVICE_STATUS=""
NEW_SERVICE_READY_STATUS=""
NC_PID_KILL_STATUS=""
PID_LISTING=""
PORT_LISTING=""
NEW_NC_PID_GREP_STATUS=""

if [ -f "${PID_FILE}" ]; then
    echo "${PID_FILE} exists."
    NC_PID=$(<"$PID_FILE")
    echo "current process pid: ${NC_PID}"
    pgrep ${NC_PID}
    if [ $? -eq 1 ]; then
        NC_PID_STATUS="UP"
    else
        NC_PID_STATUS="DOWN"
    fi
else
    echo "current process pid could not be determined:"
fi

if [ -f "${PORT_FILE}" ]; then
    echo "${PORT_FILE} exists."
    NC_PORT=$(<"$PORT_FILE")
    echo "current process port: ${NC_PORT}"
    NC_PORT_OK_STATUS="OK"
else
    echo "current process port could not be determined:"
    NC_PORT_OK_STATUS="NOTOK"
fi

if [[ "${NC_PID_STATUS}" == "UP" ]] && [[ "${NC_PORT_OK_STATUS}" == "OK" ]]; then
    echo "checking if the service is up and running"
    SERVICE_STATUS=$(wget --no-check-certificate -S -q -O - http://localhost:${NC_PORT} 2>&1 | awk '/^  HTTP/{print $2}')
    echo "Service status : ${SERVICE_STATUS}"
    #if [[ $SERVICE_STATUS =  ]]; then
    if [[ "$SERVICE_STATUS" == "200" ]]; then
        SERVICE_READY_STATUS="OK"
        echo "current process is serving alright"
    else
        SERVICE_READY_STATUS="NOTOK"
        echo "current process is not serving well"
    fi
else
    SERVICE_READY_STATUS="UNKNOWN"
    echo "current process pid or port could not be determined"
fi

if [ -f "${NEW_PORT_FILE}" ]; then
    echo "$NEW_PORT_FILE exists."
    NEW_NC_PORT=$(<"$NEW_PORT_FILE")
    echo "new port: ${NEW_NC_PORT}"

    netstat -ln | grep ":${NEW_NC_PORT}\> " 2>&1 > /dev/null 
    if [ $? -ne 0 ]; then   
        echo "new port: ${NEW_NC_PORT} is available for usage"
        socat TCP4-LISTEN:${NEW_NC_PORT},fork EXEC:./bashttpd &
        echo $!>${NEW_PID_FILE}
        if [ $? -eq 0 ]; then
            echo "new process is spawned"         
            NEW_PID=$(<"$NEW_PID_FILE")
            echo "New PID: ${NEW_PID}"
    
            if  ps -p ${NEW_PID} > /dev/null
            then
                NEW_NC_PID_GREP_STATUS="OK"
                echo "New process is running"
            else
                NEW_NC_PID_GREP_STATUS="NOTOK"
                echo "New pid could not be captured correctly"   
            fi
            #readiness check
            sleep 5

            NEW_SERVICE_STATUS=$(wget --no-check-certificate -S -q -O - http://localhost:${NEW_NC_PORT} 2>&1 | awk '/^  HTTP/{print $2}')
            if [[ "${NEW_SERVICE_STATUS}" == "200" ]]; then
                NEW_SERVICE_READY_STATUS="OK"
                echo "new process is serving alright"
                if [[ "${NC_PID_STATUS}" == "UP" ]]; then
                    kill -9 ${NC_PID}
                    sleep 5
                    if ps -p ${NC_PID} > /dev/null
                    then
                        NC_PID_KILL_STATUS="NOTOK"
                        echo "old process could not be killed successfully...manual intervention required."
                        echo "Investigate process id : ${NC_PID}"
                    else
                        NC_PID_KILL_STATUS="OK"
                        echo "old process is killed successfully"
                        # transfer the power to the new boss
                        rm -f ${PID_FILE}
                        rm -f ${PORT_FILE}
                        mv ${NEW_PID_FILE} ${PID_FILE}
                        mv ${NEW_PORT_FILE} ${PORT_FILE}
                        ls ${PID_FILE}
                        PID_LISTING=$?
                        ls ${PORT_FILE}
                        PORT_LISTING=$?
                        if [[ ${PID_LISTING} -eq 0 ]] && [[ ${PORT_LISTING} -eq 0 ]]; then
                            echo "New process pid file and port file are intact"
                            echo "****** End pof Happy path *****"
                        else
                            echo "Either New process pid file OR port file OR both are missing"
                            echo "PID FILE RETURN STATUS : ${PID_LISTING} "
                            echo "PORT FILE RETURN STATUS : ${PORT_LISTING} "
                        fi
                    fi
                else
                    echo "NC PID Status not up. : It is : ${NC_PID_STATUS}"
                fi
            else
                NEW_SERVICE_READY_STATUS="NOTOK"
                echo "new process is not serving well"
            fi   
        else
            echo "New process could not be spawned. Previous return code : $? "
        fi
    else
        echo "new port: ${NEW_NC_PORT} is not available for usage. Try another"
        #TODO: scan ports, and suggest next in queue
        counter = 0
        (( NEXT_PORT = ${NEW_NC_PORT} + 1 ))
        for i in `seq 10`
        do
            
            netstat -ln | grep ":${NEXT_PORT}\> " 2>&1 > /dev/null
            if [[ $? -ne 0 ]]; then   
                echo "Port: ${NEXT_PORT} is available for usage"
            fi
            (( NEXT_PORT = ${NEXT_PORT} + 1 ))
        done 
    fi
else 
    echo "${NEW_PORT_FILE} does not exist. Nothing to do. Another happy path ..."
fi
