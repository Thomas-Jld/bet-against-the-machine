let myp5;

function startSketch() {
    let sketch = function (p) {

        let rocketship;
        let rocketship_lift;

        let rocket_image;

        p.preload = function () {
            rocketship = p.loadImage("/batm/static/assets/rocketship.png");
            rocketship_lift = p.loadImage("/batm/static/assets/rocketship_lift.png");
            rocket_image = rocketship;
        };

        p.setup = function () {
            p.createCanvas(p.windowWidth, p.windowHeight).position(0, 0);
            p.imageMode(p.CENTER);
        };

        p.windowResized = () => {
            p.resizeCanvas(p.windowWidth, p.windowHeight);
        };

        p.draw = function () {
            p.background(0, 0, 26);
            p.image(rocket_image, p.width/2, p.height - 200, 300, 300);
        };

        p.mousePressed = function () {
            if (rocket_image === rocketship) {
                rocket_image = rocketship_lift;
            } else {
                rocket_image = rocketship;
            }
        }

    };

    myp5 = new p5(sketch);
}
