import {Controller} from "@hotwired/stimulus"
import TurnDownService from "turndown"

export default class extends Controller {
    static targets = ['chatBox', 'prompt', 'extraInputs', 'limit', 'distance'];
    static values = { token: String, image: String }

    initialize() {
        this.promptTarget.focus();
        this.embeddedChats = [];
        this.fineTunedChats = [];

        this.model = 'Fine-tuned';
        this.inProgress = false;
        this.rendering = false;
        this.turnDownService = new TurnDownService();
    }

    changeModel(event) {
        let element = event.target;
        if (this.inProgress || this.rendering) return;

        if (!element.classList.contains('active')) {
            let activeElement = document.querySelector('nav .left.column a.active');
            activeElement.classList.toggle('active');
            element.classList.toggle('active');

            this.model = element.innerText;
            this.renderConversation();
        }

        if (this.model === 'Embedded')
            this.extraInputsTarget.style.display = 'inline';
        else
            this.extraInputsTarget.style.display = 'none';
    }

    createMessage(message, type) {
        let element = document.createElement('div');
        element.classList.add(type, 'message');

        if(this.imageValue !== '' && type === 'user')
            element.innerHTML = `<div><div class="avatar" style="background-image: url('${this.imageValue}'), url('user.png')" ></div></div>`
        else
            element.innerHTML = `<div><div class="avatar"></div></div>`

        let content = document.createElement('div');
        content.classList.add('content');

        if(type === 'user')
            content.innerText = message;
        else
            content.innerHTML = message;

        element.appendChild(content);
        return element;
    }

    appendMessage(message, type) {
        this.chatBoxTarget.appendChild(this.createMessage(message, type));
    }

    renderConversation() {
        let index = 0;
        this.chatBoxTarget.innerHTML = '';

        this.rendering = true;
        this.messagesArray().forEach((message) => {
            if (index % 2 === 1)
                this.chatBoxTarget.appendChild(this.createMessage(message, 'assistant'));
            else
                this.chatBoxTarget.appendChild(this.createMessage(message, 'user'));

            index += 1;
        });
        this.promptTarget.focus();
        this.rendering = false;
    }

    messagesArray() {
        return this.model === 'Fine-tuned' ? this.fineTunedChats : this.embeddedChats;
    }

    snakeCaseModel() {
        if (this.model === 'Fine-tuned')
            return 'fine_tuned';
        else
            return 'embedded';
    }

    async chatCompletion(event) {
        let prompt = this.promptTarget.value;

        if (/^\s*$/g.test(prompt)) return;
        if (this.inProgress) return;

        this.messagesArray().push(prompt);
        this.appendMessage(prompt, 'user');
        this.appendMessage('', 'assistant');

        let lastContent = document.querySelector('.chat-room .message:last-child .content');
        lastContent.innerHTML = `<div class="ui active inline orange double loader"></div>`;
        this.scrollToBottom();

        let formData = new FormData();
        formData.append('type', this.snakeCaseModel());
        formData.append('authenticity_token', this.tokenValue);
        this.messagesArray().forEach((message) => {
            formData.append('messages[]', this.turnDownService.turndown(message));
        });

        if(this.model === 'Embedded'){
            formData.append('limit', this.limitTarget.value);
            formData.append('distance', this.distanceTarget.value);
        }

        this.promptTarget.value = '';
        this.promptTarget.style.height = '1.2em';
        this.inProgress = true;

        let response = await fetch('/chats', {
            method: 'POST',
            body: formData,
        })
        let result = await response.json();

        if(result['completion']) {
            this.messagesArray().push(result['completion']);
            lastContent.innerHTML = result['completion'];
        } else if(result['message']){
            this.messagesArray().pop();
            lastContent.innerHTML = result['message'];
        }

        this.inProgress = false;
        this.scrollToBottom();
    }

    scrollToBottom() {
        this.chatBoxTarget.scrollTo({top: this.chatBoxTarget.scrollHeight});
    }

    print(){
        let printWindow = window.open('', '', 'height=800,width=800');
        printWindow.document.write(`
        <html lang="en">
        <head>
            <title>Rently AI</title>
            <style>
                body{padding: 20px 40px; font-family: system-ui;margin: 0}
                div:nth-of-type(odd):before{content: 'user';color: dodgerblue}
                div:nth-of-type(even):before{content: 'assistant';color: mediumseagreen}
                div:before{display: block;margin-bottom: 10px;}
                div{border: 1px solid black;border-radius: 5px;padding: 15px 20px;margin-bottom: 23px}
            </style>
        </head>
        <body>
        <h3>Rently AI chat export</h3>
        `);
        this.messagesArray().forEach((message) => {
            printWindow.document.write('<div>' + message + '</div>');
        });
        printWindow.document.write('</body></html>');
        printWindow.document.close();
        printWindow.print();
    }
}
