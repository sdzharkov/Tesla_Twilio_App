import { observable, action } from 'mobx';

class CrudStore {

  @observable data = [];

  constructor() {
    this.data = [];
  }

  @action updateData = (data) => {
    this.data = data;
  }

  @action fetchUsers = () => {
    fetch('http://localhost:3001/users')
    .then(response  => {
        response.json().then(body => {
          console.log(body)
          this.updateData(body);
        })
      },
      error => {
        console.log(error)
      });
  }
}

const crudStore = new CrudStore();
export default crudStore;
