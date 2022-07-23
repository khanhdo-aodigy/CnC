import { LightningElement, track, api } from 'lwc';

var Point = function(x, y, time) {
    this.x = x;
    this.y = y;
    this.time = time || new Date().getTime();
}

var Bezier = function (startPoint, control1, control2, endPoint) {
    this.startPoint = startPoint;
    this.control1 = control1;
    this.control2 = control2;
    this.endPoint = endPoint;
};

Point.prototype.velocityFrom = function(start) {
    return (this.time !== start.time) ? this.distanceTo(start) / (this.time - start.time) : 1;
}

Point.prototype.distanceTo = function(start) {
    return Math.sqrt(Math.pow(this.x - start.x, 2) + Math.pow(this.y - start.y, 2));
}

// Returns approximated length of Bezier curve
Bezier.prototype.length = function () {
    let steps = 10,
        length = 0,
        i, t, cx, cy, px, py, xdiff, ydiff;

    for (i = 0; i <= steps; i++) {
        t = i / steps;
        cx = this._point(t, this.startPoint.x, this.control1.x, this.control2.x, this.endPoint.x);
        cy = this._point(t, this.startPoint.y, this.control1.y, this.control2.y, this.endPoint.y);
        if (i > 0) {
            xdiff = cx - px;
            ydiff = cy - py;
            length += Math.sqrt(xdiff * xdiff + ydiff * ydiff);
        }
        px = cx;
        py = cy;
    }
    return length;
};

Bezier.prototype._point = function (t, start, c1, c2, end) {
    return          start * (1.0 - t) * (1.0 - t)  * (1.0 - t)
           + 3.0 *  c1    * (1.0 - t) * (1.0 - t)  * t
           + 3.0 *  c2    * (1.0 - t) * t          * t
           +        end   * t         * t          * t;
};

export default class sdp_VehicleDeliveryCertificate_SignPad extends LightningElement {

    velocityFilterWeight = 0.7;
    minWidth = 0.5;
    maxWidth = 2.5;
    dotSize = (this.minWidth + this.maxWidth) / 2;
    penColor = 'black';
    backgroundColor = 'rgba(0,0,0,0)';
    _canvas;
    _ctx;
    _mouseButtonDown = false;
    points = [];
    _lastVelocity = 0;
    _lastWidth = (this.minWidth + this.maxWidth) / 2;
    _isEmpty = true;

    @track dataUrlForDemo;

    renderedCallback() {
        let canvas = this.template.querySelector(`[data-id="sign-pad"]`);
        
        this._canvas = canvas;
        this._ctx = canvas.getContext("2d");
        
        this._handleMouseEvents();
        this._handleTouchEvents();

        // test only
        //this.template.querySelector(`[data-id="draw-image"]`).addEventListener('click', this.onDrawing.bind(this));
        //this.template.querySelector(`[data-id="data-url"]`).addEventListener('click', this.toDataUrl.bind(this));
    }

    // clear sign pad
    clear() {
        let ctx = this._ctx, canvas = this._canvas;
        ctx.fillStyle = this.backgroundColor;
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        this._reset();

        // test
        this.onDrawing();
    }

    // method that can be invoked by parent component to get signature data url
    @api
    toDataUrl() {
        let canvas = this._canvas;
        let dataUrl = canvas.toDataURL('image/png', 1);
        this.dispatchEvent(new CustomEvent('signurl', {detail: dataUrl, bubbles: true, composed: true}));
    }

    // rebuild canvas from data URL
    fromDataUrl(dataUrl) {
        // TODO: add method to rebuild canvas
    }

    // method that draw an image from canvas data
    onDrawing() {
        let canvas = this._canvas;
        this.dataUrlForDemo = canvas.toDataURL('image/png', 1);
    }

    _handleMouseEvents() {
        this._mouseButtonDown = false;
        this._canvas.addEventListener('mousedown', this._handleMouseDown.bind(this));
        this._canvas.addEventListener('mousemove', this._handleMouseMove.bind(this));
        this.template.addEventListener('mouseup', this._handleMouseUp.bind(this));
    }

    _handleTouchEvents() {
        // Pass touch events to canvas element on mobile IE.
        this._canvas.style.msTouchAction = 'none';

        this._canvas.addEventListener("touchstart", this._handleTouchStart.bind(this));
        this._canvas.addEventListener("touchmove", this._handleTouchMove.bind(this));
        this.template.addEventListener("touchend", this._handleTouchEnd.bind(this));
    }

    _handleMouseDown(event) {
        if (event.which === 1) {
            this._mouseButtonDown = true;
            this._strokeBegin(event);
        }
    }

    _handleMouseMove(event) {
        if (this._mouseButtonDown) {
            this._strokeUpdate(event);
        }
    }

    _handleMouseUp(event) {
        if (event.which === 1 && this._mouseButtonDown) {
            this._mouseButtonDown = false;
            this._strokeEnd(event);
        }
    }

    _handleTouchStart(event) {
        let touch = event.changedTouches[0];
        this._strokeBegin(touch);
    }

    _handleTouchMove(event) {
        // Prevent scrolling.
        event.preventDefault();

        let touch = event.changedTouches[0];
        this._strokeUpdate(touch);
    }

    _handleTouchEnd(event) {
        let wasCanvasTouched = event.target === this._canvas;
        if (wasCanvasTouched) {
            event.preventDefault();
            this._strokeEnd(event);
        }
    }

    

    _strokeBegin(event) {
        this._reset();
        this._strokeUpdate(event);
    }

    _strokeEnd(event) {
        let canDrawCurve = this.points.length > 2,
            point = this.points[0];

        if (!canDrawCurve && point) {
            this._strokeDraw(point);
        }
    }

    _strokeDraw(point) {
        let ctx = this._ctx;
        ctx.beginPath();
        this._drawPoint(point.x, point.y, this.dotSize);
        ctx.closePath();
        ctx.fill();
    }

    _reset() {
        this.points = [];
        this._lastVelocity = 0;
        this._lastWidth = (this.minWidth + this.maxWidth) / 2;
        this._isEmpty = true;
        this._ctx.fillStyle = this.penColor;
    }

    _strokeUpdate(event) {
        let point = this._createPoint(event);
        this._addPoint(point);
    }

    _createPoint(event) {
        let rect = this._canvas.getBoundingClientRect();
        return new Point(
            event.clientX - rect.left,
            event.clientY - rect.top
        );
    }

    _addPoint(point) {
        let points = this.points;
        let c2, c3, curve, tmp;
        
        points.push(point);

        if (points.length > 2) {
            // To reduce the initial lag make it work with 3 points
            // by copying the first point to the beginning.
            if (points.length === 3) points.unshift(points[0]);

            tmp = this._calculateCurveControlPoints(points[0], points[1], points[2]);
            c2 = tmp.c2;
            tmp = this._calculateCurveControlPoints(points[1], points[2], points[3]);
            c3 = tmp.c1;
            curve = new Bezier(points[1], c2, c3, points[2]);
            this._addCurve(curve);

            // Remove the first element from the list,
            // so that we always have no more than 4 points in points array.
            points.shift();
        }
    }

    _calculateCurveControlPoints(s1, s2, s3) {
        let dx1 = s1.x - s2.x, dy1 = s1.y - s2.y;
        let dx2 = s2.x - s3.x, dy2 = s2.y - s3.y;

        let m1 = {x: (s1.x + s2.x) / 2.0, y: (s1.y + s2.y) / 2.0};
        let m2 = {x: (s2.x + s3.x) / 2.0, y: (s2.y + s3.y) / 2.0};

        let l1 = Math.sqrt(dx1*dx1 + dy1*dy1);
        let l2 = Math.sqrt(dx2*dx2 + dy2*dy2);

        let dxm = (m1.x - m2.x);
        let dym = (m1.y - m2.y);

        let k = l2 / (l1 + l2);
        let cm = {x: m2.x + dxm*k, y: m2.y + dym*k};

        let tx = s2.x - cm.x;
        let ty = s2.y - cm.y;

        return {
            c1: new Point(m1.x + tx, m1.y + ty),
            c2: new Point(m2.x + tx, m2.y + ty)
        };
    }

    _addCurve(curve) {
        let startPoint = curve.startPoint,
            endPoint = curve.endPoint,
            velocity, newWidth;

        velocity = endPoint.velocityFrom(startPoint);
        velocity = this.velocityFilterWeight * velocity + (1 - this.velocityFilterWeight) * this._lastVelocity;

        newWidth = this._strokeWidth(velocity);
        this._drawCurve(curve, this._lastWidth, newWidth);

        this._lastVelocity = velocity;
        this._lastWidth = newWidth;
    }

    _strokeWidth(velocity) {
        return Math.max(this.maxWidth / (velocity + 1), this.minWidth);
    }

    _drawCurve(curve, startWidth, endWidth) {
        let ctx = this._ctx,
            widthDelta = endWidth - startWidth,
            drawSteps, width, i, t, tt, ttt, u, uu, uuu, x, y;

        drawSteps = Math.floor(curve.length());
        ctx.beginPath();
        for (i = 0; i < drawSteps; i++) {
            // Calculate the Bezier (x, y) coordinate for this step.
            t = i / drawSteps;
            tt = t * t;
            ttt = tt * t;
            u = 1 - t;
            uu = u * u;
            uuu = uu * u;

            x = uuu * curve.startPoint.x;
            x += 3 * uu * t * curve.control1.x;
            x += 3 * u * tt * curve.control2.x;
            x += ttt * curve.endPoint.x;

            y = uuu * curve.startPoint.y;
            y += 3 * uu * t * curve.control1.y;
            y += 3 * u * tt * curve.control2.y;
            y += ttt * curve.endPoint.y;

            width = startWidth + ttt * widthDelta;
            this._drawPoint(x, y, width);
        }
        ctx.closePath();
        ctx.fill();
    }

    _drawPoint(x, y, size) {
        let ctx = this._ctx;

        ctx.moveTo(x, y);
        ctx.arc(x, y, size, 0, 2 * Math.PI, false);
        this._isEmpty = false;
    }

}