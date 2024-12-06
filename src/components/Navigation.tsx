import { Link } from 'react-router-dom';

export function Navigation() {
  return (
    <nav className="bg-white shadow-lg">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <Link to="/" className="text-xl font-bold">
            Leaf Coaching
          </Link>
          <div className="flex space-x-4">
            <Link
              to="/find-coach"
              className="px-4 py-2 rounded-md bg-green-500 text-white hover:bg-green-600 transition-colors"
            >
              Trouver un coach
            </Link>
          </div>
        </div>
      </div>
    </nav>
  );
} 