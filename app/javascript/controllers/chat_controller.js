import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['chatBox', 'prompt'];

    initialize() {
        this.embeddedChats = [];
        this.fineTunedChats = [];

        this.model = 'Fine-tuned';
    }

    changeModel(event) {
        let element = event.target;
        if (!element.classList.contains('active')) {
            let activeElement = document.querySelector('nav .left.column a.active');
            activeElement.classList.toggle('active');
            element.classList.toggle('active');

            this.model = element.innerText;
        }
    }

    createMessage(message, type) {
        let element = document.createElement('div');
        element.classList.add(type, 'message');
        element.innerHTML = `<div><div class="avatar"></div></div>`

        let content = document.createElement('div');
        content.classList.add('content');
        content.innerText = message;

        element.appendChild(content);
        return element;
    }

    appendMessage(message, type) {
        this.chatBoxTarget.appendChild(this.createMessage(message, type));
    }

    renderConversation() {
        let index = 0;
        this.chatBoxTarget.innerHTML = '';

        this.messagesArray.forEach((message) => {
            if (index ^ 1)
                this.chatBoxTarget.appendChild(this.createMessage(message, 'assistant'));
            else
                this.chatBoxTarget.appendChild(this.createMessage(message, 'user'));

            index += 1;
        });
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

        this.messagesArray().push(prompt);
        this.appendMessage(prompt, 'user');
        this.appendMessage('', 'assistant');

        let lastContent = document.querySelector('.chat-room .message:last-child .content');
        lastContent.innerHTML = `<div class="ui active inline orange double loader"></div>`;
        this.scrollToBottom();

        let formData = new FormData();
        formData.append('type', this.snakeCaseModel());
        this.messagesArray().forEach((message) => {
            formData.append('messages[]', message);
        });

        this.promptTarget.value = '';
        let response = await fetch('/chats', {
            method: 'POST',
            body: formData,
        })
        let result = await response.json();

        this.messagesArray().push(result['completion']);
        lastContent.innerText = result['completion'];
        this.scrollToBottom();
    }

    scrollToBottom() {
        this.chatBoxTarget.scrollTo({top: this.chatBoxTarget.scrollHeight});
    }
}
