/************************************************************************************************************************************
 *
 *	================
 *	MONITORING LAB 1
 *	================
 *
 *	THIS LAB RUNS AGAINST YOUR TEAMS DEDICATED TenantCRM AZURE SQL DATABASE. 
 *
 *	The databases are hosted on:
 * 
 *						sqlhackmiXXXXX.database.windows.net
 *
 ************************************************************************************************************************************/




/************************************************************************************************************************************
 * PART 1: USING [sys].[dm_db_resource_stats] DMV TO LOOK AT THE OVERALL DATABASE PERFORMANCE HEALTH
 ************************************************************************************************************************************/
 

SELECT * FROM sys.dm_db_resource_stats;


/*
 * Note the [avg_cpu_percent] is near 100% indicating that the CPU is under pressure.
 */





/*
 * END PART 1 - RETURN TO LAB INSTRUCTIONS
 */







/************************************************************************************************************************************
 * PART 2:	USING [sys].[dm_db_wait_stats] TO EXAMINE THE DATABASE WAIT STATS
 ************************************************************************************************************************************/
 
/* 
 * This query uses the [sys].[dm_db_wait_stats] DMV which provides detailed information about the waits encountered by all SQL threads.
 * Notice that we use a CTE to help exclude a long list irrelevant wait types and make the subsequent query simpler.
 *
 * If you want to stretch your use of DMVs Glenn Berry's excellent SQL Server performance website has a host of version specific 
 * queries and is a great resource for TSQL based performance monitoring and tuning.  https://glennsqlperformance.com/
 * 
 */


GO
WITH [Waits] 
AS (SELECT *
    FROM sys.dm_db_wait_stats WITH (NOLOCK)
	WHERE waiting_tasks_count > 0 --ignore wait types that havenlt occured
	AND [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
		N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
		N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT', 
		N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', 
		N'MEMORY_ALLOCATION_EXT', N'ONDEMAND_TASK_QUEUE',
		N'PREEMPTIVE_HADR_LEASE_MECHANISM', N'PREEMPTIVE_SP_SERVER_DIAGNOSTICS',
		N'PREEMPTIVE_ODBCOPS',
		N'PREEMPTIVE_OS_LIBRARYOPS', N'PREEMPTIVE_OS_COMOPS', N'PREEMPTIVE_OS_CRYPTOPS',
		N'PREEMPTIVE_OS_PIPEOPS', N'PREEMPTIVE_OS_AUTHENTICATIONOPS',
		N'PREEMPTIVE_OS_GENERICOPS', N'PREEMPTIVE_OS_VERIFYTRUST',
		N'PREEMPTIVE_OS_FILEOPS', N'PREEMPTIVE_OS_DEVICEOPS', N'PREEMPTIVE_OS_QUERYREGISTRY',
		N'PREEMPTIVE_OS_WRITEFILE',
		N'PREEMPTIVE_XE_CALLBACKEXECUTE', N'PREEMPTIVE_XE_DISPATCHER',
		N'PREEMPTIVE_XE_GETTARGETSTATE', N'PREEMPTIVE_XE_SESSIONCOMMIT',
		N'PREEMPTIVE_XE_TARGETINIT', N'PREEMPTIVE_XE_TARGETFINALIZE',
		N'PREEMPTIVE_XHTTP',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
		N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
		N'QDS_ASYNC_QUEUE',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'RESOURCE_GOVERNOR_IDLE',
		N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
		N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
		N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'WAIT_XTP_RECOVERY',
		N'XE_BUFFERMGR_ALLPROCESSED_EVENT', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_LIVE_TARGET_TVF', N'XE_TIMER_EVENT')
	)
SELECT TOP 10 
	   wait_type AS WaitType
	 , wait_time_ms AS TotalWait_ms
	 , waiting_tasks_count AS TotalWaitCount
	 , CONVERT(DECIMAL(5,2), (100.0 *  wait_time_ms / SUM (wait_time_ms) OVER())) AS [WaitPercentage]
FROM waits
ORDER BY wait_time_ms DESC






/*
 * END PART 2 - RETURN TO LAB INSTRUCTIONS
 */






 /************************************************************************************************************************************
  * PART 3:	USING [sys].[dm_exec_requests] and [sys].[dm_exec_sql_text] DMVs TO DETERMINE LONG RUNNING BATCHES
  ************************************************************************************************************************************/
 
/* 
 * This query joins the [sys].[dm_exec_requests] and [sys].[dm_exec_sql_text] DMVs to return the longest running queries and critically 
 * their offending SQL.
 * 
 * Note that [dm_exec_sql_text] is actually a table-valued function (TVF) hence the use of the CROSS APPLY as TVFs can't be used in a 
 * normal join operation. The CROSS APPLY therefore produces an inner-join between [dm_exec_requests] and [dm_exec_sql_text] 
 * 
 */

 SELECT 
     req.session_id
   , req.start_time
   , req.blocking_session_id
   , req.cpu_time 'cpu_time_ms'
   , req.last_wait_type
   , object_name(st.objectid,st.dbid) 'ObjectName' 
   , substring
      (REPLACE
        (REPLACE
          (SUBSTRING
            (ST.text
            , (req.statement_start_offset/2) + 1
            , (
               (CASE statement_end_offset
                  WHEN -1
                  THEN DATALENGTH(ST.text)  
                  ELSE req.statement_end_offset
                  END
                    - req.statement_start_offset)/2) + 1)
       , CHAR(10), ' '), CHAR(13), ' '), 1, 512)  AS statement_text 
FROM sys.dm_exec_requests AS req  
   CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) as ST
ORDER BY cpu_time desc;
GO




/*
 * END PART 3 - RETURN TO LAB INSTRUCTIONS
 */





