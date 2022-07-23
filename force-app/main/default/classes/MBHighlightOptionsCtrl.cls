public with sharing class MBHighlightOptionsCtrl {
    public MBHighlightOptionsCtrl( ApexPages.StandardController controller ) {}

    public void executeBatchBuilSpecHLOs() {
        Database.executeBatch(new MB_BatchBuildSpecHighlightOptions(), 200);
    }

    public void executeBatchSVMSpecHLOs() {
        Database.executeBatch(new MB_BatchSVMSpecHighlightOptions(), 200);
    }
}