import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Navigation } from './components/Navigation';
import LoginForm from './components/auth/LoginForm';
import FindCoach from './pages/FindCoach';

function App() {
  return (
    <BrowserRouter>
      <div className="min-h-screen bg-gray-50">
        <Navigation />
        <div className="container mx-auto px-4 py-8">
          <Routes>
            <Route path="/" element={<LoginForm />} />
            <Route path="/find-coach" element={<FindCoach />} />
          </Routes>
        </div>
      </div>
    </BrowserRouter>
  );
}

export default App;