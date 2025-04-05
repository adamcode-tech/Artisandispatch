import { useEffect, useState } from 'react';
import '../styles/splashScreen.css';

const SplashScreen = ({ onFinished }: { onFinished: () => void }) => {
  const [isAnimating, setIsAnimating] = useState(true);

  // Optimisation du chargement pour une expérience plus fluide
  useEffect(() => {
    // Fonction simplifiée pour configurer le fond blanc
    const setupBackground = () => {
      document.documentElement.style.backgroundColor = 'white';
      document.body.style.backgroundColor = 'white';
      
      const root = document.getElementById('root');
      if (root) {
        root.style.backgroundColor = 'white';
      }
    };
    
    // Appliquer immédiatement
    setupBackground();
    
    // Réduire le délai d'animation à 500ms au lieu de 1000ms
    const timer = setTimeout(() => {
      setIsAnimating(false);
      
      // Réduire également le délai de fondu à 200ms
      setTimeout(() => {
        onFinished();
      }, 200);
    }, 500);

    return () => {
      clearTimeout(timer);
    };
  }, [onFinished]);

  // Utiliser une version simplifiée et plus légère du composant
  if (!isAnimating) return null;
  
  return (
    <div 
      className="fixed inset-0 flex items-center justify-center bg-white z-50 transition-opacity duration-200"
      style={{ opacity: isAnimating ? 1 : 0 }}
    >
      <div className="flex flex-col items-center">
        <div className="text-2xl font-bold text-primary-600 mb-3">SmartCoach</div>
        <div className="w-6 h-6 border-2 border-primary-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    </div>
  );
};

export default SplashScreen;
