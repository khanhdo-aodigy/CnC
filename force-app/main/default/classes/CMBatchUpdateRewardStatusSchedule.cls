/** ***************
 * Class Name: CMBatchUpdateRewardStatusSchedule
 * Description: Schedulable class to invoke batch CMBatchUpdateRewardStatus
 * Note:
 *       without sharing is used so that this batch will
 *       run on System mode.
 * Revision History: 
 * Date(YYYYMMDD)                Name                      Description
 * 20200907                      khanh.do@aodigy           Created Initial Version 
 * 
** ***************/ 
public without sharing class CMBatchUpdateRewardStatusSchedule implements Schedulable{
    public void execute(SchedulableContext sc){
        CMBatchUpdateRewardStatus batchUpdateRewardStatus = new CMBatchUpdateRewardStatus();
        Database.executeBatch(batchUpdateRewardStatus);
    }
}