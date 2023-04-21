## HClib's statistic feature

In order to take more detailed look about task scheduling, we can enable HClib's statistic feature. It will allow use to trace each worker's statistcs and give their task performance overview including work stealing.

!!! warning

	Please notice that when enabling the statistic feature, some overhead will be added, so do not use this feature with performance sensitive tasks

To enable statistic feature, we need to reinstall the HClib with `--enable-stats`  option
```
cd $HOME/hclib
./clobber.sh
./clean.sh
git fetch && git checkout bale3_actor
./install.sh --enable-production --enable-stats
source hclib-install/bin/hclib_setup_env.sh
```

### Example stats output

```
===== HClib statistics: =====  
Worker 0: 4 tasks executed, 5 tasks spawned, 4 tasks scheduled, 0 steals, 0 stolen tasks, -nan tasks per steal, stolen from = [ 0 ]  
Total: 4 tasks, 2 end finishes, 0 future waits, 0 non-blocking end finishes, 1 ctx creates, 2 yields, 1.000000 iters per yield on average
```