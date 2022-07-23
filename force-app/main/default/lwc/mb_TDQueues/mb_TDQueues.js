import { LightningElement, api } from 'lwc';

export default class Mb_TDQueues extends LightningElement {
    todayQueuedReqs;
    queuesCnt;

    @api
    get queuedRequests() {
        return this.todayQueuedReqs;
    }

    set queuedRequests(value) {
        let tmpReqs = JSON.parse(JSON.stringify(value));
        tmpReqs.forEach(req => {
            req.CreatedDate = new Date(req.CreatedDate).toLocaleString('en-SG', { timeZone: 'Asia/Singapore', hour12: true });
        })

        this.todayQueuedReqs = tmpReqs;
        this.queuesCnt       = this.todayQueuedReqs.length;
    }

    closeQueues() {
        this.dispatchEvent(new CustomEvent('closequeues'));
    }
}