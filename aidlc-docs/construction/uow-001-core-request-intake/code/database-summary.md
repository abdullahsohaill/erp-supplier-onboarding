# UOW-001 Database Summary

The authoritative `database-schema-design.md` remains ground truth. Seven ordered DDL migrations translate it without adding a migration-history table or changing the finalized model.

| Measure | Verified |
|---|---:|
| Application tables | 18 |
| Physical columns | 189 |
| Foreign keys | 17 |
| Views | 4 |
| Package specifications/bodies | 15 / 15 |
| Invalid objects | 0 |

The external manifest installs seven DDL migrations, two validators, 30 package assets, five ORDS modules, and two ORDS security assets: 46 ordered assets total. Checksums are recorded in ignored evidence. Unchanged reruns skip verified assets while validators always run; a changed package specification forces package recompilation.

Three deterministic seed scripts populate every table. Identity sequences are synchronized, retry count/history is checked, and a full stop/start preserved the Oracle volume before migrations, seeds, parity, and health passed again.
