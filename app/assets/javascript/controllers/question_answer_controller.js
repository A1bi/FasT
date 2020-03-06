import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['answer'];

  disclose() {
    this.element.classList.toggle('disclosed');
  }
}
