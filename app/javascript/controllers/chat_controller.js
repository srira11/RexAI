import {Controller} from "@hotwired/stimulus"
import TurnDownService from "turndown"

export default class extends Controller {
    static targets = ['chatBox', 'prompt'];
    static values = { token: String }

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
    }

    createMessage(message, type) {
        let element = document.createElement('div');
        element.classList.add(type, 'message');
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

        this.promptTarget.value = '';
        this.promptTarget.style.height = '1.2em';
        this.inProgress = true;

        let response = await fetch('/chats', {
            method: 'POST',
            body: formData,
        })
        let result = await response.json();

        this.messagesArray().push(result['completion']);
        lastContent.innerHTML = result['completion'];
        this.inProgress = false;
        this.scrollToBottom();
    }

    scrollToBottom() {
        this.chatBoxTarget.scrollTo({top: this.chatBoxTarget.scrollHeight});
    }
}
