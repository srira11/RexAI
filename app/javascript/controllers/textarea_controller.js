import {Controller} from "@hotwired/stimulus"

export default class extends Controller {

    initialize(){
        this.index = 1;
        this.promptTarget.focus();
    }
    expand(event) {
        if(this.index !== 5) {
            this.index += 1;
            event.target.style.height = this.index * 1.2 + 'em';
        }
    }

    minimize(event){
        if(event.keyCode === 8) {
            this.index = (event.target.value.match(/\n/g) || []).length + 1;
            if(this.index > 5) this.index = 5;
            event.target.style.height = this.index * 1.2 + 'em';
        }
    }
}