//
//  semaphoreController.m
//  Interviewdrill
//   https://www.jianshu.com/p/93c376081188
//  Created by atoz on 2021/10/29.
//

#import "semaphoreController.h"

@interface semaphoreController ()

@property (nonatomic, strong) dispatch_semaphore_t sem;

@end

@implementation semaphoreController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//输出结果为：
//2018-08-19 22:47:31.118267+0800 TestDate[19223:293646] run task 2
//2018-08-19 22:47:31.118267+0800 TestDate[19223:293642] run task 1
//2018-08-19 22:47:32.118646+0800 TestDate[19223:293642] complete task 1
//2018-08-19 22:47:32.118646+0800 TestDate[19223:293646] complete task 2
//2018-08-19 22:47:32.118824+0800 TestDate[19223:293644] run task 3
//2018-08-19 22:47:33.121652+0800 TestDate[19223:293644] complete task 3
//由于信号量的初始值为2，代表最多开两个线程，所以等待任务1和任务2执行之后才会执行任务3。
- (void)dispatchSignal {
    //创建信号量，参数：信号量的初值，如果小于0则会返回NULL
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //等待降低信号量
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 1");
        sleep(1);
        NSLog(@"complete task 1");
        //提高信号量
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_async(queue, ^{
        //等待降低信号量
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 2");
        sleep(1);
        NSLog(@"complete task 2");
        //提高信号量
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_async(queue, ^{
        //等待降低信号量
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 3");
        sleep(1);
        NSLog(@"complete task 3");
        //提高信号量
        dispatch_semaphore_signal(semaphore);
    });
}

- (void)dispatchSignal2 {
    // 测试
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
//        [self semaphore_signal];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
             dispatch_semaphore_signal(sem);
          });
        
        long semaphoreWait = dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
        NSLog(@"semaphoreWait: %ld", semaphoreWait);
        
        if (semaphoreWait == 0) {
            // 降低信号量成功
            NSLog(@"降低信号量成功");
        } else {
            // 降低信号量失败，线程休眠直到15s后会走到这里
            NSLog(@"降低信号量失败，线程休眠直到15s后会走到这里");
        }
    });
}

// 使用信号量完成同步操作
//2020-03-03 17:30:20.447806+0800 TestSemaphore[73321:2061719] semaphoreWait: 0
//2020-03-03 17:30:20.447978+0800 TestSemaphore[73321:2061719] 降低信号量成功
- (void)dispatchSignal3 {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        self.sem = sem;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self semaphore_signal];
            long semaphoreWait = dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
            NSLog(@"semaphoreWait: %ld", semaphoreWait);
            if (semaphoreWait == 0) {
                // 降低信号量成功
                NSLog(@"降低信号量成功");
            } else {
                // 降低信号量失败，线程休眠直到15s后会走到这里
                NSLog(@"降低信号量失败，线程休眠直到15s后会走到这里");
            }
        });
}

- (void)semaphore_signal {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_semaphore_signal(self.sem);
    });
}

//dispatch_semaphore_wait第二个参数改为DISPATCH_TIME_FOREVER,代表线程一直处于等待状态，不会输出任何东西
- (void)dispatchSignal4 {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        self.sem = sem;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
    //        [self semaphore_signal];
            long semaphoreWait = dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            NSLog(@"semaphoreWait: %ld", semaphoreWait);
            if (semaphoreWait == 0) {
                // 降低信号量成功
                NSLog(@"降低信号量成功");
            } else {
                // 降低信号量失败，线程休眠直到15s后会走到这里
                NSLog(@"降低信号量失败，线程休眠直到15s后会走到这里");
            }
        });
}

//dispatch_semaphore 闪退问题
//019-07-29 11:12:02.300190+0800 TEST[10987:950615] +[CATransaction synchronize] called within transaction
//2019-07-29 11:12:02.439848+0800 TEST[10987:950615] wait
//2019-07-29 11:12:02.439934+0800 TEST[10987:950615] signal
//2019-07-29 11:12:02.439962+0800 TEST[10987:950615] wait
//2019-07-29 11:12:02.439986+0800 TEST[10987:950615] signal
//2019-07-29 11:12:02.440009+0800 TEST[10987:950615] wait
//2019-07-29 11:12:02.440032+0800 TEST[10987:950615] signal
//2019-07-29 11:12:02.440054+0800 TEST[10987:950615] wait
- (void)dispatchSignal5 {
    dispatch_semaphore_t semp = dispatch_semaphore_create(1);
      dispatch_block_t block = ^{
          dispatch_semaphore_signal(semp);
          NSLog(@"signal");
      };

      for (NSInteger i = 0; i < 4; i++) {
          NSLog(@"wait");
          dispatch_semaphore_wait(semp, DISPATCH_TIME_FOREVER);
          if (i > 2) {//当I大于2时，只执行 wait ，没执行signal
              break;
          }else{ //当I小于等于2时，signal与wait是配对的
              block();
          }
      }
}

//原因是信号量的销毁会调用_dispatch_semaphore_dispose函数，而此函数会执行信号当前值与初始化值的比较，如果小于初始化值，则直接抛出崩溃。
//我们看下此函数的源码：

//static void
//_dispatch_semaphore_dispose(dispatch_semaphore_t dsema)
//{
//    //信号量的当前值小于初始化，会发生闪退。因为信号量已经被释放了
//    if (dsema->dsema_value < dsema->dsema_orig) {
//        DISPATCH_CLIENT_CRASH(
//                "Semaphore/group object deallocated while in use");
//    }
//
//#if USE_MACH_SEM
//    kern_return_t kr;
//    //释放信号，这个信号是dispatch_semaphore使用的信号
//    if (dsema->dsema_port) {
//        kr = semaphore_destroy(mach_task_self(), dsema->dsema_port);
//        DISPATCH_SEMAPHORE_VERIFY_KR(kr);
//    }
//    //释放信号，这个信号是dispatch_group使用的信号
//    if (dsema->dsema_waiter_port) {
//        kr = semaphore_destroy(mach_task_self(), dsema->dsema_waiter_port);
//        DISPATCH_SEMAPHORE_VERIFY_KR(kr);
//    }
//#elif USE_POSIX_SEM
//    int ret = sem_destroy(&dsema->dsema_sem);
//    DISPATCH_SEMAPHORE_VERIFY_RET(ret);
//#endif
//
//    _dispatch_dispose(dsema);
//}

//因此。当信号量的当前值小于初始化，释放信号量时，会导致崩溃，简而言之就是，signal的调用次数一定要大于等于wait的调用次数，否则导致崩溃。
@end
