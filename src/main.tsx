import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { 
  Route, 
  Navigate,
  createBrowserRouter,
  RouterProvider,
  createRoutesFromElements
} from 'react-router-dom';
import App from './App.tsx';
import Admin from './pages/Admin.tsx';
import ErrorBoundary from './components/ErrorBoundary.tsx';
import './index.css';

console.log('Initializing router...');

const router = createBrowserRouter(
  createRoutesFromElements(
    <>
      <Route 
        path="/" 
        element={<App />} 
        errorElement={<ErrorBoundary><App /></ErrorBoundary>}
      />
      <Route 
        path="/admin" 
        element={<Admin />}
        errorElement={<ErrorBoundary><Admin /></ErrorBoundary>}
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </>
  )
);

console.log('Router configuration:', {
  routes: router.routes.map(route => ({
    path: route.path,
    id: route.id
  }))
});

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ErrorBoundary>
      <RouterProvider router={router} />
    </ErrorBoundary>
  </StrictMode>
);