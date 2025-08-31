import { defineStore } from 'pinia';

const useAuthStore = defineStore("auth", {
  state: () => ({
    token: null,
    email: null,
    role: null
  }),
  actions: {
    loadFromStorage() {
    },
    setToken(token) {
      this.token = token;
    },
    setUser(email, role) {
      this.email = email;
      this.role = role;
    },
    clear() {
      this.token = null;
      this.email = null;
      this.role = null;
    }
  }
});

export { useAuthStore as u };
//# sourceMappingURL=auth-D2H_Myyg.mjs.map
