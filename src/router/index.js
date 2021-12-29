import { createRouter, createWebHistory } from 'vue-router'
import Home from '@/components/Home.vue'
import Login from '@/components/Login.vue'
import Project from '@/components/Project.vue'
import Recipe from '@/components/Recipe.vue'
import Dataset from '@/components/Dataset.vue'
import ValidationController from '@/components/Validation/Controller.vue'
import Jobs from '@/components/Jobs.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {name: 'root', path: '/matchID', redirect: { name: 'home' }},
    {name: 'login', path: '/matchID/login', component: Login},
    {name: 'home', path: '/matchID/projects', component: Home},
    {name: 'jobs', path: '/matchID/jobs', component: Jobs},
    {name: 'job', path: '/matchID/jobs/:job', component: Jobs},
    {name: 'project', path: '/matchID/projects/:project', component: Project},
    {name: 'recipe', path: '/matchID/projects/:project/recipes/:recipe', component: Recipe},
    {name: 'dataset', path: '/matchID/projects/:project/datasets/:dataset', component: Dataset},
    {name: 'validation', path: '/matchID/projects/:project/datasets/:dataset/validation', component: ValidationController}
  ]
})

export default router;
