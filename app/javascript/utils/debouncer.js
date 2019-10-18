/* Function to debounce events */

export default function debounce(func, wait) {
  let timeoutID = null;
  const delay = isNaN(wait) ? 300 : wait;

  const closureDebounce = (...args) => {
    const delayed = () => {
      timeoutID = null;
      func.apply(this, args);
    };

    clearTimeout(timeoutID);
    timeoutID = setTimeout(delayed, delay);
  };

  closureDebounce.cancel = () => {
    if (timeoutID) {
      clearTimeout(timeoutID);
      return true;
    }
    return false;
  };

  return closureDebounce;
}
