select task_id, 
  seqno, 
  fragno, 
  last_frag, 
  source_id, 
  epoch_number, 
  eventid,
  greatest(0, cast(t.applied_latency + (now() - t.update_timestamp) as UNSIGNED)) as 'applied_latency',
  update_timestamp, 
  shard_id, 
  extract_timestamp
from @{REPL_SVC_SCHEMA}.trep_commit_seqno t
  where t.applied_latency=
   (select max(applied_latency) from @{REPL_SVC_SCHEMA}.trep_commit_seqno)
  limit 1;
