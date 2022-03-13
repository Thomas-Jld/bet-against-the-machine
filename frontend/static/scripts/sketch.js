let myp5;

function startSketch() {
    let sketch = function (p) {

        let rocketship;
        let rocketship_lift;

        let rocket_image;

        let y_rocket_pos = 0;
        let y_challenge_pos = -100;

        let progress = 0;
        let progress_start = 0;

        let scenarios = [scenario0, scenario1, scenario2, scenario3];
        let scenario_index = 0;

        p.preload = function () {
            rocketship = p.loadImage("/batm/static/assets/rocketship.png");
            rocketship_lift = p.loadImage("/batm/static/assets/rocketship_lift.png");
            rocket_image = rocketship;
        };

        p.setup = function () {
            p.createCanvas(p.windowWidth, p.windowHeight).position(0, 0);
            p.imageMode(p.CENTER);
            p.textAlign(p.CENTER);
            p.textSize(32);
            p.textFont("Open Sans");
            p.fund_input = p.createInput(0.1, "number").position(25, 130).size(125, 25).attribute("min", 0).attribute("step", 0.00001);
            p.fund_button = p.createButton("Fund").position(160, 130).size(100, 25).mousePressed(fund);
            p.bet_input = p.createInput(0.1, "number").position(25, 160).size(125, 25).attribute("min", 0).attribute("step", 0.00001);
            p.bet_button = p.createButton("Bet").position(160, 160).size(100, 25).mousePressed(start);
            p.end_button = p.createButton("End").position(115, 190).size(70, 30).attribute("disabled", true).mousePressed(end);
        };

        p.windowResized = () => {
            p.resizeCanvas(p.windowWidth, p.windowHeight);
        };

        p.draw = function () {
            scenarios[scenario_index]();
            p.ath();
        };

        p.ath = function () {
            p.push();
            p.translate(150, 150);
            p.noStroke();
            p.fill(255);
            p.textSize(24);
            p.text("Balance (ether)", 0, -100);
            p.textSize(52);
            p.text(balance, 0, -50);
            p.pop();
        }

        p.mousePressed = function () {
            // scenario_index = (scenario_index + 1) % scenarios.length;
            // if (rocket_image === rocketship) {
            //     rocket_image = rocketship_lift;
            // } else {
            //     rocket_image = rocketship;
            // }
        }

        function scenario0(){
            p.background(0, 0, 26);
            p.image(rocket_image, p.width/2, p.height - 200, 300, 300);
        }

        function scenario1(){
            p.background(0, 0, 26);
            p.stroke(255);
            p.strokeWeight(2);
            p.line(p.width/4, y_challenge_pos, 3*p.width/4, y_challenge_pos);
            p.image(rocket_image, p.width/2, p.height - 200 - y_rocket_pos, 300, 300);
            y_rocket_pos = p.lerp(y_rocket_pos, p.height/4, 0.05);
            y_challenge_pos = p.lerp(y_challenge_pos, 3*p.height/4 - 200, 0.01);
            if((y_challenge_pos - (3*p.height/4 - 200))**2 < 100){
                challenge();
            }
            // progress = p.millis();
        }

        function scenario2(){
            p.background(0, 0, 26);
            p.stroke(255);
            p.strokeWeight(2);
            p.line(p.width/4, y_challenge_pos, 3*p.width/4, y_challenge_pos);
            p.image(rocket_image, p.width/2, p.height - 200 - y_rocket_pos, 300, 300);
            y_challenge_pos = p.lerp(y_challenge_pos, 1.2*p.height, 0.05);
            if((y_challenge_pos - 1.2*p.height)**2 < 50){
                y_challenge_pos = -100;
                scenario_index = 1;
            }
        }

        function scenario3(){
            p.background(0, 0, 26);
            p.stroke(255);
            p.strokeWeight(2);
            p.line(p.width/4, y_challenge_pos, 3*p.width/4, y_challenge_pos);
            p.image(rocket_image, p.width/2, p.height - 200 - y_rocket_pos, 300, 300);
            y_challenge_pos = p.lerp(y_challenge_pos, -100, 0.05);
            y_rocket_pos = p.lerp(y_rocket_pos, 0, 0.05);
            if((y_challenge_pos - (-100))**2 < 100){
                scenario_index = 0;
            }
        }

        p.start = function () {
            // progress_start = millis();
            y_rocket_pos = 0;
            rocket_image = rocketship_lift;
            scenario_index = 1;
            p.end_button.removeAttribute("disabled");
        }

        p.challenge = function () {
            scenario_index = 2;
        }

        p.end = function () {
            scenario_index = 3;
            rocket_image = rocketship;
            p.end_button.attribute("disabled", true);
        }

    };

    myp5 = new p5(sketch);
}
